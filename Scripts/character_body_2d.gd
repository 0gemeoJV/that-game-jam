extends CharacterBody2D

const SPEED = 300.0
var JUMP_VELOCITY = -600.0
const BULLET_SCENE = preload("res://prefabs/bullets.tscn")
const BOUNCE_VELOCITY = -900.0
const DEATH_JUMP_FORCE = -400.0 

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")

@onready var remote_transform := $remote as RemoteTransform2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D 
@onready var marker: Marker2D = $Marker2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D # Ajuste o caminho caso o nó tenha outro nome
@onready var hurtbox: CollisionShape2D = $hurtbox/HurtCollision

@onready var knockback_vector:= Vector2.ZERO

var collision_position_x: float
var marker_position_x: float
var hurtbox_position_x: float
var current_bullet: Node2D = null
var direction: int = 1
var player_life = 1
var is_dead = false

# Variáveis para controlar o tempo dos tiros
var shoot_timer: float = 0.0
const SHOOT_DURATION: float = 0.2 # Ajuste conforme a duração da sua animação


signal player_damage(player_life:int)
signal _recharging

func _ready():
	marker_position_x = marker.position.x
	collision_position_x = collision_shape.position.x
	hurtbox_position_x = hurtbox.position.x

# Função chamada diretamente PELA ANIMAÇÃO no frame correto do tiro
func spawn_bullet():
	if current_bullet != null and is_instance_valid(current_bullet):
		return
	var bullet_instance = BULLET_SCENE.instantiate() as Node2D
	bullet_instance.direction = direction
	bullet_instance.global_position = marker.global_position
	get_parent().add_child(bullet_instance)
	current_bullet = bullet_instance
	emit_signal("_recharging")

func bounce():
	velocity.y = BOUNCE_VELOCITY

func inside_water(surface_y: float):
	#print("Dentro da água")
	JUMP_VELOCITY = -800

func out_water():
	JUMP_VELOCITY = -600	
	
func _physics_process(delta: float) -> void:
	if is_dead:
		velocity += get_gravity() * delta
		move_and_slide()
		
		# Reinicia a cena quando cair completamente da tela (ajuste a altura se necessário)
		if global_position.y > 1000:
			get_tree().reload_current_scene()
		return
	
	# 1. Gravidade
	if not is_on_floor():
		velocity += get_gravity() * delta

	# 2. Pulo
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	# Pulo variável: se soltar o botão de pulo enquanto ainda está subindo, corta a velocidade vertical
	if Input.is_action_just_released("ui_accept") and velocity.y < 0:
		velocity.y *= 0.5 #
	
	# 3. Movimentação horizontal
	var input_axis := Input.get_axis("ui_left", "ui_right")
	if input_axis != 0:
		direction = int(sign(input_axis))
		velocity.x = input_axis * SPEED
		animated_sprite.flip_h = direction > 0
		marker.position.x = marker_position_x * direction
		collision_shape.position.x = collision_position_x * direction
		hurtbox.position.x = hurtbox_position_x * direction
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# 4. Controle da AnimationTree
	if state_machine != null:
		var current_node = state_machine.get_current_node()

		# Se estiver em qualquer animação de tiro, decrementamos o temporizador
		if current_node in ["shoot", "run_shoot", "jump_shoot", "fall_shoot"]:
			shoot_timer -= delta
			if shoot_timer <= 0:
				# Quando o tempo do tiro acaba, voltamos para o estado físico correto
				if not is_on_floor():
					if velocity.y < 0:
						state_machine.travel("jump")
					else:
						state_machine.travel("fall")
				elif input_axis != 0:
					state_machine.travel("run")
				else:
					state_machine.travel("idle")
		
		# Verificação de Ar vs Chão
		if not is_on_floor():
			# Se já estiver rodando um tiro no ar, deixamos tocar até o fim
			if current_node == "jump_shoot" or current_node == "fall_shoot":
				pass 
			# Se apertar para atirar no ar: decide entre subida (jump_shoot) e queda (fall_shoot)
			elif Input.is_action_just_pressed("Shoot"):
				shoot_timer = SHOOT_DURATION
				if velocity.y < 0:
					state_machine.travel("jump_shoot")
				else:
					state_machine.travel("fall_shoot")
			# Movimentação normal no ar
			elif velocity.y < 0:
				state_machine.travel("jump")
			else:
				state_machine.travel("fall")
		else:
			# Se estiver no chão, gerencia os tiros de chão e movimentação normal
			if current_node in ["shoot", "run_shoot"]:
				pass 
			elif Input.is_action_just_pressed("Shoot") and input_axis == 0:
				shoot_timer = SHOOT_DURATION
				state_machine.travel("shoot")
			elif Input.is_action_just_pressed("Shoot") and input_axis != 0:
				shoot_timer = SHOOT_DURATION
				state_machine.travel("run_shoot")
			elif input_axis != 0:
				state_machine.travel("run")
			else:
				state_machine.travel("idle")

	if knockback_vector != Vector2.ZERO:
		velocity = knockback_vector
	move_and_slide()

 # Replace with function body.

func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		emit_signal('player_damage',player_life)
		if player_life  < 0:
			die()
			print('Morreu')
		else:
			# Descobre a direção com base na posição do inimigo em relação ao player
			var direction_x = sign(global_position.x - body.global_position.x)
			if direction_x == 0:
				direction_x = 1 # Evita que seja zero caso estejam na mesma posição exata
			# Aplica o knockback para o lado oposto ao inimigo (multiplicando a força pela direção)
			take_damage(Vector2(2000 * direction_x, -200))
			#print('Tomei dano')
	pass # Replace with function body.

#função para tomar dano
func take_damage(knockback_force:= Vector2.ZERO, duration:= 0.25):
	player_life -= 1
	if knockback_force != Vector2.ZERO:
		knockback_vector = knockback_force
		var knoback_tween = get_tree().create_tween()
		knoback_tween.tween_property(self, "knockback_vector",Vector2.ZERO, duration)
		animated_sprite.modulate = Color(1,0,0,1)
		knoback_tween.tween_property(animated_sprite, "modulate", Color(1,1,1,1), duration)

func follow_camera(camera):
	var camera_path = camera.get_path()#pega o caminho da camera
	remote_transform.remote_path = camera_path#recebe o caminho da camera
	
# Função principal de morte
func die():
	if is_dead:
		return
	is_dead = true
	
	# 1. Desativa a colisão com plataformas e a hurtbox para não tomar mais dano
	collision_shape.set_deferred("disabled", true)
	if hurtbox:
		hurtbox.set_deferred("disabled", true)
	
	# 2. Desconecta a câmera para ela parar de seguir o player (o player some por baixo)
	remote_transform.remote_path = NodePath("")
	
	# 3. Aplica o impulso inicial para cima e zera o eixo X
	velocity.y = DEATH_JUMP_FORCE
	velocity.x = 0
	
	state_machine.travel("Die")
