extends CharacterBody2D

const SPEED = 300.0
var JUMP_VELOCITY = -600.0
const BULLET_SCENE = preload("res://prefabs/bullets.tscn")
# Força do impulso da mola (ajuste o valor se quiser que ele pule mais alto ou mais baixo)
const BOUNCE_VELOCITY = -600.0

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")

# Referências para os nós da cena
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D # Verifique se o nome na cena é AnimatedSprite2D
@onready var marker: Marker2D = $Marker2D

# Variável para guardar a distância inicial X do Marker
var marker_position_x: float

# Variável para guardar a referência da bala ativa
var current_bullet: Node2D = null

var direction: int = 1

func _ready():
	# Guarda a posição local X inicial do Marker
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
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if Input.is_action_pressed("Shoot"):
		shoot()

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var input_axis := Input.get_axis("ui_left", "ui_right")
	if input_axis != 0:
		direction = int(sign(input_axis))
		state_machine.travel("run")
		velocity.x = input_axis * SPEED
		
		# Vira o AnimatedSprite2D e ajusta a posição do Marker para o lado correto
		animated_sprite.flip_h = direction < 0
		marker.position.x = marker_position_x * direction
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		state_machine.travel("idle") # Retorna para a animação parado

	move_and_slide()
