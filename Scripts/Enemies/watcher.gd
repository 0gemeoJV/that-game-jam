extends StaticBody2D

@onready var viewField: Area2D = $ViewField
@onready var rayCast: RayCast2D = $ViewField/RayCast2D
@onready var collision: CollisionPolygon2D = $ViewField/CollisionShape2D

# Parâmetros do Pêndulo (Campo de Visão)
@export var rotation_speed: float = 2.0  
@export var max_angle_degrees: float = 45.0 
@export var tracking_speed: float = 10.0 # Velocidade com que o inimigo gira para o player

var time_accumulator: float = 0.0
var base_rotation: float = 0.0

var current_player = null
var is_player_in_range: bool = false
var original_ray_target: Vector2

func _ready() -> void:
	base_rotation = viewField.rotation
	original_ray_target = rayCast.target_position

func _physics_process(delta: float) -> void:
	if current_player:
		player_found(delta)
		collision.rotation_degrees = -90.0
	else:
		pendulum_movement(delta)
		collision.rotation_degrees = 0.0
		rayCast.target_position = original_ray_target

func pendulum_movement(delta: float) -> void:
	time_accumulator += delta * rotation_speed
	var max_angle_rads = deg_to_rad(max_angle_degrees)
	viewField.rotation = base_rotation + sin(time_accumulator) * max_angle_rads

func player_found(delta: float) -> void:
	# 1. Calcula a direção em relação ao jogador
	var direction_to_player = current_player.global_position - viewField.global_position
	var target_angle = direction_to_player.angle()
	
	# 2. Suaviza a rotação usando lerp_angle para evitar saltos bruscos quando o player se vira
	viewField.global_rotation = lerp_angle(viewField.global_rotation, target_angle, tracking_speed * delta)
	
	# 3. Atualiza o RayCast
	rayCast.target_position = rayCast.to_local(current_player.global_position)
	rayCast.force_raycast_update()
	
	if rayCast.is_colliding():
		var collider = rayCast.get_collider()
		if collider == current_player:
			print('olha ele')
			# Reseta o flag de saída para garantir que ele não perca o player por conta da Area2D
			is_player_in_range = true
			return
		else:
			print('obstáculo no caminho (visão bloqueada)')
			# Se bateu em uma parede, perde o player de vista
			current_player = null
	
	# Se o player saiu fisicamente da Area2D E o raycast não está mais vendo diretamente
	if not is_player_in_range:
		current_player = null

func _on_view_field_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		current_player = body
		is_player_in_range = true
		print("Jogador entrou no cone de visão.")

func _on_view_field_body_exited(body: Node2D) -> void:
	if body == current_player:
		is_player_in_range = false
		print("Jogador saiu dos limites da Area2D, checando linha de visão...")
