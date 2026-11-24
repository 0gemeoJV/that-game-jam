extends CharacterBody2D

var body: Node2D = null
const SPEED = 250.0
const ACCELERATION = 600.0

#Este é o sinal que será emitido pelo condutor elétrico quando... 
#a bola entrar na área de detecção, caso duplique o meta_box,... 
#lembre se conectar o sinal manualmente no inspetor,... 
#pois o Godot não conecta automaticamente os sinais de instâncias duplicadas
func _on_electric_conductor_follow_ball(ball_body: Node2D) -> void:
	body = ball_body
	#print('Implementar função de seguir a bola')
	pass # Replace with function body.

#função para seguir a bola, chamada pelo sinal do condutor elétrico
func follow_ball(delta: float) -> void:
	var target_velocity_x = 0.0
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if body:
		var direction = sign(body.global_position.x - global_position.x)
		target_velocity_x = direction * SPEED
	
	velocity.x = move_toward(velocity.x, target_velocity_x, ACCELERATION * delta)
	move_and_slide()

func _physics_process(delta: float):
	follow_ball(delta)
