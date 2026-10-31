extends CharacterBody2D
#procurar video aula depois
#@onready var target = $"../CharacterBody2D"
var SPEED = 150 
var is_chasing = false
var player: Node2D = null

func _physics_process(delta: float) -> void:
	
	if is_chasing == true:
		position += (player.position - position) / SPEED 
		#move_and_slide()

func _on_vision_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		is_chasing = true
		#print("Player")
		player = body
func _on_vision_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		is_chasing = false
		#print("Player saiu")
		player = null
