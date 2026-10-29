extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const  BULLET_SCENE = preload("res://prefabs/bullets.tscn")
# Força do impulso da mola (ajuste o valor se quiser que ele pule mais alto ou mais baixo)
const BOUNCE_VELOCITY = -600.0

#MARKER_2D
#Esta variável esta pegando o marker2d
@onready var marker: Marker2D = $Marker2D
#Variável que irá receber o Marker position
var marker_position
# Variável para guardar a referência da bala que está ativa na tela
var current_bullet: Node2D = null

var direction: int = 1

func _ready():
	marker_position = marker.position

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

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if Input.is_action_pressed("Shoot"):
		shoot()

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_axis := Input.get_axis("ui_left", "ui_right")
	if input_axis != 0:
		# Atualiza a direção da classe apenas quando o jogador se move
		direction = int(sign(input_axis))
		velocity.x = input_axis * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
