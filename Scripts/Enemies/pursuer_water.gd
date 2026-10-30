extends Pursuer 

# Sobrescrevemos a função de movimento para o comportamento aquático (Gravidade 0)
func aplicar_movimento(delta: float) -> void:
	# Como ele está na água, anulamos a gravidade no eixo Y (ele fica flutuando/estável)
	velocity.y = move_toward(velocity.y, 0, ACCELERATION * delta)
	
	# Mesma lógica de perseguição horizontal do Pursuer normal
	var target_velocity_x = 0.0
	if is_chasing and current_target != null:
		var direction = sign(current_target.global_position.x - global_position.x)
		target_velocity_x = direction * SPEED
		if direction != 0:
			$Sprite2D.scale.x = direction
			
	velocity.x = move_toward(velocity.x, target_velocity_x, ACCELERATION * delta)
	
	# Executa a movimentação
	move_and_slide()
