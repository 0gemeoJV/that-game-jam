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

func _ready():
	marker_position_x = marker.position.x

func shoot():
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
	# 1. Adiciona a gravidade se não estiver no chão
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Variável auxiliar para sabermos se o botão de tiro está pressionado
	var is_shooting = Input.is_action_pressed("Shoot")
	
	# Tiro (pode acontecer a qualquer momento)
	if is_shooting:
		shoot()

	# 2. Tratamento de Pulo
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

	# 4. Controle da AnimationTree baseado no estado físico e de tiro
	if not is_on_floor():
		# No ar continua normal por enquanto
		if velocity.y < 0:
			state_machine.travel("jump")
		else:
			state_machine.travel("fall")
	else:
		# No chão: verificamos se está atirando parado, correndo ou parado normal
		if is_shooting and input_axis == 0:
			state_machine.travel("shoot") # Toca o tiro parado se estiver no chão e sem andar
		elif input_axis != 0:
			state_machine.travel("run")
		else:
			state_machine.travel("idle")

	move_and_slide()
