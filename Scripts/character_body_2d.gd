extends CharacterBody2D

const SPEED = 300.0
var JUMP_VELOCITY = -600.0
const BULLET_SCENE = preload("res://prefabs/bullets.tscn")
const BOUNCE_VELOCITY = -600.0

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D 
@onready var marker: Marker2D = $Marker2D

var marker_position_x: float
var current_bullet: Node2D = null
var direction: int = 1

# Variáveis para controlar o tempo dos tiros
var shoot_timer: float = 0.0
const SHOOT_DURATION: float = 0.2 # Ajuste conforme a duração da sua animação

func _ready():
	marker_position_x = marker.position.x

# Função chamada diretamente PELA ANIMAÇÃO no frame correto do tiro
func spawn_bullet():
	if current_bullet != null and is_instance_valid(current_bullet):
		return
	var bullet_instance = BULLET_SCENE.instantiate() as Node2D
	bullet_instance.direction = direction
	bullet_instance.global_position = marker.global_position
	get_parent().add_child(bullet_instance)
	current_bullet = bullet_instance

func bounce():
	velocity.y = BOUNCE_VELOCITY

func inside_water(surface_y: float):
	print("Dentro da água")
	JUMP_VELOCITY = -800

func out_water():
	JUMP_VELOCITY = -600	
	
func _physics_process(delta: float) -> void:
	# 1. Gravidade
	if not is_on_floor():
		velocity += get_gravity() * delta

	# 2. Pulo
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# 3. Movimentação horizontal
	var input_axis := Input.get_axis("ui_left", "ui_right")
	if input_axis != 0:
		direction = int(sign(input_axis))
		velocity.x = input_axis * SPEED
		animated_sprite.flip_h = direction > 0
		marker.position.x = marker_position_x * direction
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

	move_and_slide()
