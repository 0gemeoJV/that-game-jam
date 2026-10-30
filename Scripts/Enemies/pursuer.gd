extends CharacterBody2D

const SPEED = 250.0
const ACCELERATION = 600.0

var is_chasing: bool = false
# Variável para guardar o alvo atual (pode ser o Player ou a Bola)
var current_target: Node2D = null
var player_ref: Node2D = null #guarda a referência do player separadamente

func _physics_process(delta: float) -> void:
	# Adiciona gravidade se não estiver no chão
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# VERIFICAÇÃO DE VALIDADE DO ALVO:
	# Se tivermos um alvo, checamos se ele ainda existe (útil para quando a bola é destruída)
	if current_target != null:
		if not is_instance_valid(current_target):
			# A bola sumiu! Vamos ver se o player ainda existe para focar nele
			if player_ref != null and is_instance_valid(player_ref):
				current_target = player_ref # Transfere o foco imediatamente para o player!
				is_chasing = true
			else:
				#Volta ao estado inicial.
				current_target = null
				is_chasing = false
	
	var target_velocity_x = 0.0
	
	if is_chasing and current_target != null:
		# Persegue a posição X do alvo atual (bola ou player)
		var direction = sign(current_target.global_position.x - global_position.x)
		target_velocity_x = direction * SPEED
		
		# Vira o sprite para o lado do alvo
		if direction != 0:
			$Sprite2D.scale.x = direction
	
	# Aplica a inércia/derrapagem
	velocity.x = move_toward(velocity.x, target_velocity_x, ACCELERATION * delta)

	move_and_slide()

# Conecte o sinal "body_entered" da VisionArea aqui
func _on_vision_area_body_entered(body: Node2D) -> void:
	# PRIORIDADE 1: Se a bola entrar no campo de visão, ele se distrai e foca nela imediatamente
	# (Verificamos se o corpo tem o método da bola, como "inside_water" ou se é um RigidBody2D)
	if body.name == "bullets":
		print("Bolaaa!!")
		current_target = body
		is_chasing = true
	
	# PRIORIDADE 2: Se for o player (e o inimigo não estiver ocupado com a bola)
	elif (body.name == "CharacterBody2D") and current_target == null:
		current_target = body
		is_chasing = true
