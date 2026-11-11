extends CharacterBody2D

const SPEED = 400.0
var JUMP_VELOCITY = -700.0
const BULLET_SCENE = preload("res://prefabs/bullets.tscn")
const BOUNCE_VELOCITY = -1000.0
const DEATH_JUMP_FORCE = -400.0 
const ENVIRONMENT_COLLISION_MASK = 1
const WALL_CONTACT_TOLERANCE = 2.0
const BULLET_WALL_CLEARANCE = 2.0

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var remote_transform := $remote as RemoteTransform2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D 
@onready var marker: Marker2D = $Marker2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D # Ajuste o caminho caso o nó tenha outro nome
@onready var hurtbox: CollisionShape2D = $hurtbox/HurtCollision

@onready var knockback_vector:= Vector2.ZERO

@onready var audioJump: AudioStreamPlayer2D = $Audio/AudioJump
@onready var audioRecover: AudioStreamPlayer2D = $Audio/RecoverLife
@onready var audioBall: AudioStreamPlayer2D = $Audio/AudioBall
@onready var audioDie: AudioStreamPlayer2D = $Audio/AudioDie
@onready var spawn_marker: Marker2D = $SpawnPlayer

var collision_position_x: float
var marker_position_x: float
var hurtbox_position_x: float
var bullet_forward_extent_right: float
var bullet_forward_extent_left: float
var current_bullet: Node2D = null
var direction: int = 1
var player_life = 3
var is_dead = false
var is_completing = false
var camera_path: NodePath

# Variáveis para controlar o tempo dos tiros
var shoot_timer: float = 0.0
const SHOOT_DURATION: float = 0.2 # Ajuste conforme a duração da sua animação


signal player_damage(player_life:int)
signal _recharging
signal life_charging(player_life: int)


func _ready():
	marker_position_x = marker.position.x
	collision_position_x = collision_shape.position.x
	hurtbox_position_x = hurtbox.position.x
	GameManager.set_spawn_position(spawn_marker.global_position)
	_cache_bullet_collision_extents()

func _cache_bullet_collision_extents() -> void:
	var bullet_template := BULLET_SCENE.instantiate() as Node2D
	if bullet_template == null:
		push_error("The bullet scene root must be a Node2D.")
		return

	var bullet_collision_shape := bullet_template.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if bullet_collision_shape == null or bullet_collision_shape.shape == null:
		push_error("The bullet scene must have a CollisionShape2D with a shape.")
		bullet_template.free()
		return

	var bounds := bullet_collision_shape.shape.get_rect()
	var half_width := bounds.size.x * absf(bullet_collision_shape.scale.x) * 0.5
	bullet_forward_extent_right = bullet_collision_shape.position.x + half_width
	bullet_forward_extent_left = -bullet_collision_shape.position.x + half_width
	bullet_template.free()

func _update_marker_for_wall() -> void:
	# Define a posição base local do marcador com base na direção do player
	marker.position.x = marker_position_x * direction

	# Calcula o espaço necessário para a bala (tamanho da bala + folga)
	var bullet_forward_extent: float = bullet_forward_extent_right if direction > 0 else bullet_forward_extent_left
	var required_clearance: float = bullet_forward_extent + BULLET_WALL_CLEARANCE

	# Configura o raio de busca na direção em que o player está olhando
	var ray_length := absf(marker_position_x) + required_clearance + 10.0
	var ray_start := global_position
	var ray_end := ray_start + Vector2(direction * ray_length, 0.0)
	
	var query := PhysicsRayQueryParameters2D.create(ray_start, ray_end, ENVIRONMENT_COLLISION_MASK)
	query.exclude = [get_rid()]
	var hit := get_world_2d().direct_space_state.intersect_ray(query)
	
	# Se não houver parede no caminho, mantém o marcador na posição normal
	if hit.is_empty():
		return

	var hit_position: Vector2 = hit["position"]
	var shape_bounds := collision_shape.shape.get_rect()
	var player_half_width: float = shape_bounds.size.x * absf(collision_shape.global_scale.x) * 0.5
	var player_front_edge_x: float = collision_shape.global_position.x + direction * player_half_width
	
	# Distância atual entre a frente do player e a parede
	var distance_to_wall: float = direction * (hit_position.x - player_front_edge_x)

	# Se a parede estiver mais próxima do que o espaço que a bala precisa,
	# reposicionamos o marcador para antes da parede, evitando que a bala nasça dentro dela.
	if absf(distance_to_wall) < required_clearance:
		var safe_marker_x: float = hit_position.x - direction * required_clearance
		marker.global_position = Vector2(safe_marker_x, marker.global_position.y)

# Função chamada diretamente PELA ANIMAÇÃO no frame correto do tiro
func spawn_bullet():
	if current_bullet != null and is_instance_valid(current_bullet):
		current_bullet.queue_free()
	var bullet_instance = BULLET_SCENE.instantiate() as Node2D
	bullet_instance.direction = direction
	_update_marker_for_wall()
	bullet_instance.global_position = marker.global_position
	get_parent().add_child(bullet_instance)
	current_bullet = bullet_instance
	emit_signal("_recharging")

func bounce():
	velocity.y = BOUNCE_VELOCITY
	play_sound(audioBall)

func inside_water(surface_y: float):
	#print("Dentro da água")
	JUMP_VELOCITY = -800
	
func play_sound(stream_player: AudioStreamPlayer2D) -> void:
	# Aplica uma leve variação aleatória de pitch antes de tocar
	stream_player.pitch_scale = randf_range(0.9, 1.1)
	stream_player.play()

func out_water():
	JUMP_VELOCITY = -600	
	
func _physics_process(delta: float) -> void:
	if is_completing:
		return

	if is_dead:
		velocity += get_gravity() * delta
		move_and_slide()
		
		# Respawns after the death animation has carried the player off-screen.
		if global_position.y > 1000:
			GameManager.respawn_player(self)
		return
	
	# 1. Gravidade
	if not is_on_floor():
		velocity += get_gravity() * delta

	# 2. Pulo
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		play_sound(audioJump)
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
	_update_marker_for_wall()

 # Replace with function body.

func _on_hurtbox_body_entered(body: Node2D) -> void:
	if is_completing:
		return

	if body.is_in_group("Spikes"):
		player_life = 0
		emit_signal('player_damage',player_life)
		die()
	if body.is_in_group("enemies"):
		player_life -= 1
		emit_signal('player_damage',player_life)
		if player_life  < 1:
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
	
	
	if knockback_force != Vector2.ZERO:
		knockback_vector = knockback_force
		var knoback_tween = get_tree().create_tween()
		knoback_tween.tween_property(self, "knockback_vector",Vector2.ZERO, duration)
		animated_sprite.modulate = Color(1,0,0,1)
		knoback_tween.tween_property(animated_sprite, "modulate", Color(1,1,1,1), duration)

func follow_camera(camera):
	camera_path = camera.get_path()
	remote_transform.remote_path = camera_path


func respawn_at(position: Vector2) -> void:
	global_position = position
	velocity = Vector2.ZERO
	knockback_vector = Vector2.ZERO
	player_life = 3
	is_dead = false
	direction = 1
	animated_sprite.flip_h = false
	animated_sprite.modulate = Color.WHITE
	marker.position.x = marker_position_x
	collision_shape.position.x = collision_position_x
	hurtbox.position.x = hurtbox_position_x
	collision_shape.set_deferred("disabled", false)
	hurtbox.set_deferred("disabled", false)
	remote_transform.remote_path = camera_path
	animation_tree.active = true
	state_machine.travel("idle")
	audioDie.stop()
	life_charging.emit(player_life)
	
# Função principal de morte
func die():
	if is_dead or is_completing:
		return
	is_dead = true
	GameManager.on_player_died()
	
	# 1. Desativa a colisão com plataformas e a hurtbox para não tomar mais dano
	collision_shape.set_deferred("disabled", true)
	if hurtbox:
		hurtbox.set_deferred("disabled", true)
	
	# 2. Desconecta a câmera para ela parar de seguir o player (o player some por baixo)
	remote_transform.remote_path = NodePath("")
	
	# 3. Aplica o impulso inicial para cima e zera o eixo X
	velocity.y = DEATH_JUMP_FORCE
	velocity.x = 0
	play_sound(audioDie)
	state_machine.travel("Die")


func _on_life_item_life_charge() -> void:
	if player_life < 3:
		player_life += 1
		emit_signal('life_charging',player_life)
		play_sound(audioRecover)
		
	pass # Replace with function body.


func prepare_for_ending() -> bool:
	if is_dead or is_completing:
		return false
	if not animation_player.has_animation("desligando"):
		push_error("A animação 'desligando' não foi encontrada no AnimationPlayer do jogador.")
		return false

	is_completing = true
	velocity = Vector2.ZERO
	collision_shape.set_deferred("disabled", true)
	hurtbox.set_deferred("disabled", true)
	state_machine.travel("idle")
	return true


func play_shutdown_animation(duration: float) -> void:
	animation_tree.active = false
	var previous_speed_scale := animation_player.speed_scale
	animation_player.speed_scale = animation_player.get_animation("desligando").length / duration
	animation_player.play("desligando")
	await animation_player.animation_finished
	animation_player.speed_scale = previous_speed_scale
