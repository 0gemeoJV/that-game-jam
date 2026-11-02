extends Node2D

@onready var player := $CharacterBody2D as CharacterBody2D
@onready var camera := $Camera2D as Camera2D

#var count_damage = 3

func _ready() -> void:
	player.follow_camera(camera)


#func _on_character_body_2d_player_damage() -> void:
#	count_damage -= 1
#	print("player_life:", count_damage)
#	pass # Replace with function body.
