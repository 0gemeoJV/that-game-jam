extends StaticBody2D

@onready var viewField: Area2D = $ViewField
@onready var rayCast: RayCast2D = $ViewField/RayCast2D
@onready var collision: CollisionPolygon2D = $ViewField/CollisionShape2D


# Parâmetros do Pêndulo (Campo de Visão)
@export var rotation_speed: float = 2.0  
@export var max_angle_degrees: float = 45.0 
var time_accumulator: float = 0.0
var base_rotation: float = 0.0

var current_player = null
var is_player_in_range: bool = false

func _ready() -> void:
	base_rotation = viewField.rotation

func _physics_process(delta: float) -> void:
	if current_player:
		# Chama a função dedicada a tratar quando o jogador é encontrado/visto
		player_found(delta)
		collision.rotation_degrees = -90.0
		
	else:
		# Se não há jogador, faz o movimento de pêndulo normal
		pendulum_movement(delta)
		collision.rotation_degrees = 0

func pendulum_movement(delta: float) -> void:
	time_accumulator += delta * rotation_speed
	var max_angle_rads = deg_to_rad(max_angle_degrees)
	viewField.rotation = base_rotation + sin(time_accumulator) * max_angle_rads

func player_found(_delta: float) -> void:
	# 1. Calcula a direção em relação à origem global do viewField
	var direction_to_player = current_player.global_position - viewField.global_position
	
	# 2. Aplica a rotação global no ViewField
	viewField.global_rotation = direction_to_player.angle()
	
	# 3. Rotaciona a forma de colisão em -90 graus quando o player é encontrado
	# (Substitua 'CollisionPolygon2D' pelo nome exato do seu nó de colisão se for diferente)
	
	
	# 4. Atualiza o RayCast para checar se há linha de visão limpa
	rayCast.target_position = rayCast.to_local(current_player.global_position)
	rayCast.force_raycast_update()
	
	if rayCast.is_colliding():
		var collider = rayCast.get_collider()
		if collider == current_player:
			print('olha ele')
			return
		else:
			print('obstáculo no caminho')
	
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
