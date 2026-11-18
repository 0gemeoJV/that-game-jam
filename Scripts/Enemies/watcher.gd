extends StaticBody2D

@onready var viewField: Area2D = $ViewField
@onready var rayCast: RayCast2D = $ViewField/RayCast2D
@onready var collision: CollisionPolygon2D = $ViewField/CollisionShape2D

# Parâmetros do Pêndulo (Campo de Visão)
@export var rotation_speed: float = 1.5
@export var max_angle_degrees: float = 45.0 

var time_accumulator: float = 0.0
var base_global_rotation: float = 0.0

var current_player = null
var is_player_in_range: bool = false
var original_ray_target: Vector2

func _ready() -> void:
	# Salvamos a rotação global inicial como âncora fixa
	base_global_rotation = viewField.global_rotation
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
	
	# Movimento de pêndulo suave baseado em coordenadas globais
	viewField.global_rotation = base_global_rotation + sin(time_accumulator) * max_angle_rads

func player_found(_delta: float) -> void:
	# 1. Aponta instantaneamente para o player usando o vetor global (sem lerp/tremor)
	var direction_to_player = current_player.global_position - viewField.global_position
	viewField.global_rotation = direction_to_player.angle()
	
	# 2. Sincroniza o acumulador para que o pêndulo saiba exatamente onde parou
	var current_offset = clamp((viewField.global_rotation - base_global_rotation) / deg_to_rad(max_angle_degrees), -1.0, 1.0)
	time_accumulator = asin(current_offset)
	
	# 3. Atualiza o RayCast para checar linha de visão limpa
	rayCast.target_position = rayCast.to_local(current_player.global_position)
	rayCast.force_raycast_update()
	
	if rayCast.is_colliding():
		var collider = rayCast.get_collider()
		if collider == current_player:
			is_player_in_range = true
			return
		else:
			current_player = null
	
	if not is_player_in_range:
		current_player = null

func _on_view_field_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") or body.is_in_group("Ball"):
		current_player = body
		is_player_in_range = true
		print("Jogador entrou no cone de visão.")

func _on_view_field_body_exited(body: Node2D) -> void:
	if body == current_player:
		is_player_in_range = false
		print("Jogador saiu dos limites da Area2D, checando linha de visão...")
