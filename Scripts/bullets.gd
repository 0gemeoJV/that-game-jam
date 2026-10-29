extends RigidBody2D

var bullet_speed := 400.0
var direction : int = 2
var in_water : bool = false
var force_float : float = 350.0
#var has_fired := false

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

#func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
#	if inside_water():
		# Anula parte ou toda a gravidade e aplica uma força empurrando para cima
		# Diminuímos a velocidade linear vertical (damping) para simular a resistência da água
#		state.linear_velocity.y *= 0.95 
		
		# Aplica um empuxo para cima para fazê-la subir até o topo
#		state.apply_central_force(Vector2(0, -force_float))

#func inside_water():
#	in_water = true
#	linear_velocity *= 0.5
	
#func out_water():
#	in_water = false
