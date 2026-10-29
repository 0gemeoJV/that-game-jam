extends RigidBody2D

var bullet_speed := 900.0
var direction : int = 1
var in_water : bool = false
var force_float : float = 350.0
#var has_fired := false
# Variável para guardar o limite de altura da água
var water_surface_y: float = 0.0

func _ready() -> void:
	# Aplica o impulso inicial assim que a bala nasce
	# O eixo Y começa em 0 para ela ir reto, e a gravidade cuida de fazê-la cair depois
	apply_central_impulse(Vector2(bullet_speed * direction, 0))

func _on_timer_timeout() -> void:
	queue_free()

# Esta função é chamada quando qualquer corpo entra no detector de cima
func _on_jump_detector_body_entered(body: Node2D) -> void:
	# Verifica se o corpo que colidiu é o Player (baseado no nome ou grupo)
	if body.name == "CharacterBody2D":
		# Chama uma função de impulso no player que vamos criar agora
		if body.has_method("bounce"):
			body.bounce() # Replace with function body.

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
