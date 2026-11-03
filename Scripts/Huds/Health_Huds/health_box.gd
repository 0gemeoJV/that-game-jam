extends Panel

@onready var animationPlayer: AnimationPlayer = $AnimationPlayer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.



	pass # Replace with function body.


func _on_health_container_take_damage() -> void:
	animationPlayer.play("transition_decreasing")
	pass # Replace with function body.
