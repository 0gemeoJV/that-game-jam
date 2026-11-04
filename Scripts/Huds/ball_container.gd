extends Control

@onready var ball_charge: Panel = $BallCharge
@onready var animation_tree: AnimationTree = ball_charge.get_node("AnimationTree")
@onready var state_machine = animation_tree.get("parameters/playback")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_player__recharging() -> void:
	state_machine.start(&"charging",true)
	
	
	pass # Replace with function body.
