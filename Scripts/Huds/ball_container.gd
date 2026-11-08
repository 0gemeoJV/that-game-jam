extends Control

@onready var ball_charge: Panel = $BallCharge
@onready var animation_tree: AnimationTree = ball_charge.get_node("AnimationTree")
@onready var state_machine = animation_tree.get("parameters/playback")



func _on_player__recharging() -> void:
	state_machine.start(&"charging",true)
	
	
	pass # Replace with function body.
