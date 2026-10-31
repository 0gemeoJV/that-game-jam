#class_name Pursuer
extends CharacterBody2D

const SPEED = 250.0
const ACCELERATION = 600.0

var is_chasing: bool = false
var current_target: Node2D = null
var player_ref: Node2D = null

# A lista que armazena quem está na área de visão
var targets_in_vision: Array[Node2D] = []

func _physics_process(delta: float) -> void:
	
	# Limpa da lista objetos que foram destruídos
	targets_in_vision = targets_in_vision.filter(func(t): return is_instance_valid(t))
	
	# VERIFICAÇÃO DE VALIDADE DO ALVO ATUAL:
	if current_target != null:
		if not is_instance_valid(current_target):
			#print("--- A BOLA FOI DESTRUÍDA! ---")
			# Remove o alvo inválido da lista se ainda estiver lá
			targets_in_vision.erase(current_target)
			# Escolhe o próximo da lista que sobrou
			escolher_proximo_alvo()
	aplicar_movimento(delta)

# Criamos esta função virtual no base para o inimigo terrestre usar
func aplicar_movimento(delta: float) -> void:
	# Adiciona gravidade se não estiver no chão	
	if not is_on_floor():
		velocity += get_gravity() * delta
	var target_velocity_x = 0.0
	
	if is_chasing and current_target != null:
		var direction = sign(current_target.global_position.x - global_position.x)
		target_velocity_x = direction * SPEED
		
		if direction != 0:
			$Sprite2D.scale.x = direction
	
	velocity.x = move_toward(velocity.x, target_velocity_x, ACCELERATION * delta)
	move_and_slide()

# Função auxiliar para olhar a lista e definir quem perseguir (Prioridade: Bola > Player)
func escolher_proximo_alvo() -> void:
	var nova_bola: Node2D = null
	var novo_player: Node2D = null
	
	for target in targets_in_vision:
		if target.is_in_group("Ball"):
			nova_bola = target
			break # Bola tem prioridade máxima
		elif target.is_in_group("Player"):
			novo_player = target
			
	if nova_bola != null:
		current_target = nova_bola
		is_chasing = true
		#print("Novo alvo definido (Bola): ", current_target)
	elif novo_player != null:
		current_target = novo_player
		is_chasing = true
		#print("Novo alvo definido (Player): ", current_target)
	else:
		current_target = null
		is_chasing = false
		#print("Nenhum alvo restante na área. Voltando ao estado inicial.")

# Conecte o sinal "body_entered" da VisionArea aqui
func _on_vision_area_body_entered(body: Node2D) -> void:
	if (body.is_in_group("Player") or body.has_method("inside_water")) and not body in targets_in_vision:
		targets_in_vision.append(body)
		#print("-> ENTROU NA ÁREA: ", body, " | Lista atual: ", targets_in_vision)
		
		if body.is_in_group("Player"):
			player_ref = body
			if current_target == null:
				current_target = body
				is_chasing = true
				#print("Foco inicial no Player.")
		elif body.has_method("inside_water"):
			#print("Bolaaa detectada!! Roubando o foco.")
			current_target = body
			is_chasing = true

# Conecte o sinal "body_exited" da VisionArea aqui
func _on_vision_area_body_exited(body: Node2D) -> void:
	if body in targets_in_vision:
		targets_in_vision.erase(body)
		#print("<- SAIU DA ÁREA: ", body, " | Lista atual: ", targets_in_vision)
		
		# Se o alvo que saiu era exatamente quem o inimigo estava perseguindo...
		if body == current_target:
			#print("O alvo atual saiu da área! Escolhendo quem sobrou...")
			escolher_proximo_alvo()
