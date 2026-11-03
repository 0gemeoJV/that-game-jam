extends HBoxContainer

@onready var healthbox3: Panel = $healthbox3
@onready var healthbox2: Panel = $healthbox2
@onready var healthbox1: Panel = $healthbox

signal take_damage

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_player_player_damage(player_life) -> void:
	print(player_life)
	
	if player_life == 1:
		healthbox3.visible = false
	elif player_life == 0:
		healthbox2.visible =false
	elif player_life == -1:
		healthbox1.visible = false
	emit_signal("take_damage")
	
	
	pass # Replace with function body.
