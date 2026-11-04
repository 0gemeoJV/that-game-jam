extends RigidBody2D

const explosion = preload("res://prefabs/explosion.tscn")

var bullet_speed := 900.0
var direction : int = 1
var in_water : bool = false
var has_exploded := false
var force_float : float = 350.0
#var has_fired := false
# Variável para guardar o limite de altura da água
var water_surface_y: float = 0.0

#@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var rayDown: RayCast2D = $RayDown
@onready var rayRight: RayCast2D = $RayRight
@onready var rayUp: RayCast2D = $RayUp
@onready var rayLeft: RayCast2D = $RayLeft
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")


func _ready() -> void:
	# Aplica o impulso inicial assim que a bala nasce
	# O eixo Y começa em 0 para ela ir reto, e a gravidade cuida de fazê-la cair depois
	animation_tree.active = true
	state_machine.travel(&"ball_rolling")
	apply_central_impulse(Vector2(bullet_speed * direction, 0))
	

func _on_timer_timeout() -> void:
	queue_free()

# Esta função é chamada quando qualquer corpo entra no detector de cima
func _on_jump_detector_body_entered(body: Node2D) -> void:
	# Verifica se o corpo que colidiu é o Player (baseado no nome ou grupo)
	if body.is_in_group("Player"):
		# Chama uma função de impulso no player que vamos criar agora
		#print("PLayer aki :D")
		rayDown.force_raycast_update()
		rayRight.force_raycast_update()
		rayUp.force_raycast_update()
		rayLeft.force_raycast_update()

		var hit_from_top_or_bottom := rayDown.get_collider() == body or rayUp.get_collider() == body
		var hit_from_left_or_right := rayRight.get_collider() == body or rayLeft.get_collider() == body

		if hit_from_top_or_bottom and hit_from_left_or_right:
			var player_offset := body.global_position - global_position
			if absf(player_offset.y) >= absf(player_offset.x):
				state_machine.start(&"ball_horizontal", true)
			else:
				state_machine.start(&"ball_vertical", true)
		elif hit_from_top_or_bottom:
			state_machine.start(&"ball_horizontal", true)
		elif hit_from_left_or_right:
			state_machine.start(&"ball_vertical", true)
		else:
			var player_offset := body.global_position - global_position
			if absf(player_offset.y) >= absf(player_offset.x):
				state_machine.start(&"ball_horizontal", true)
			else:
				state_machine.start(&"ball_vertical", true)

		if body.has_method("bounce"):
			body.bounce() 
	if body.name == "pursuer_water" or body.is_in_group("Spikes"):
		if not has_exploded:
			has_exploded = true
			var explosion_instance: GPUParticles2D = explosion.instantiate()
			get_tree().current_scene.add_child(explosion_instance)
			explosion_instance.global_position = global_position
			explosion_instance.emitting = true
			_on_timer_timeout()

func _physics_process(delta: float) -> void:
	if in_water:
		# Exemplo simples: diminui a velocidade horizontal por causa da resistência da água
		linear_velocity.x = move_toward(linear_velocity.x, 0, 400 * delta)
		
		# Se a bala ainda estiver abaixo do topo da água, continua subindo
		if global_position.y > water_surface_y:
			# Empurra a bala para cima (quanto mais negativo, mais rápido ela sobe)
			# Aplicamos uma força contrária à gravidade para ela flutuar
			apply_central_force(Vector2(0, -100.0))
		else:
			# Se chegou no topo ou passou, zera a velocidade vertical e trava na posição da superfície
			linear_velocity.y = 0
			gravity_scale = 0.0 # Desativa a gravidade para ela flutuar estática
			global_position.y = water_surface_y # Garante que ela fique exatamente na linha do topo

# Agora a água passa a posição do topo para a bola
func inside_water(surface_y: float):
	in_water = true
	#print('dentro dágua')
	water_surface_y = surface_y
	gravity_scale = -0.125
	linear_velocity *= 0.5
	
func out_water():
	in_water = false
	gravity_scale = 1.0
	#print('fora dágua')
