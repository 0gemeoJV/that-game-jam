extends StaticBody2D

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")
var is_green = false

func _on_area_collision_body_entered(body: Node2D) -> void:
	if body.is_in_group('Ball'):
		if is_green == false:
			state_machine.travel("transition")
			is_green = true
		else:
			return
		#print('Toca a animação de virar plataforma')
	pass # Replace with function body.
