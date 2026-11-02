extends StaticBody2D

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")

func _on_area_collision_body_entered(body: Node2D) -> void:
	if body.name == "bullets":
		state_machine.travel("transition")
		print('Toca a animação de virar plataforma')
	pass # Replace with function body.
