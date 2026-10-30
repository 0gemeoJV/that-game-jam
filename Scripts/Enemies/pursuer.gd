extends CharacterBody2D


const SPEED = 150.0

# Variáveis de controle
var player: CharacterBody2D = null
var is_chasing: bool = false

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	
	if is_chasing and player != null:
		# Calcula a direção horizontal em direção ao player (-1 para esquerda, 1 para direita)
		var direction = sign(player.global_position.x - global_position.x)
		velocity.x = direction * SPEED
		
		if direction != 0:
			$Sprite2D.scale.x = direction # Assume que o sprite olha originalmente para a direita
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	# Add the gravity.
	
	move_and_slide()


func _on_vision_area_body_entered(body: Node2D) -> void:
	if body.name == "CharacterBody2D": #adicionar um grupo player aqui depois
		player = body
		is_chasing = true
