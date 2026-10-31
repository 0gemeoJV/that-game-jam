extends CharacterBody2D
#procurar video aula depois
@onready var target = $"../CharacterBody2D"
var SPEED = 200 
var is_chasing = false
const STOP_DISTANCE = 30.0 # Distância para parar antes de colar no player

func _physics_process(delta: float) -> void:
	if is_chasing == true and is_instance_valid(target):
		var distance = position.distance_to(target.position)
		
		# Só se move se estiver longe o suficiente do player
		if distance > STOP_DISTANCE:
			var direction = (target.position - position).normalized()
			velocity = direction * SPEED
			look_at(target.position)
		else:
			# Para o movimento quando chega perto para não grudar
			velocity = Vector2.ZERO
			
		move_and_slide()

func _on_vision_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		is_chasing = true

func _on_vision_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		is_chasing = false
		velocity = Vector2.ZERO
