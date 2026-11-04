extends Node2D

const EXPLOSION_SCENE = preload("res://prefabs/explosion.tscn")

@onready var player := $CharacterBody2D as CharacterBody2D
@onready var camera := $Camera2D as Camera2D

#var count_damage = 3

func _ready() -> void:
	player.follow_camera(camera)
	_warm_up_explosion()


func _warm_up_explosion() -> void:
	var warmup: GPUParticles2D = EXPLOSION_SCENE.instantiate()
	add_child(warmup)
	warmup.global_position = player.global_position
	warmup.modulate.a = 0.0
	warmup.emitting = true


#func _on_character_body_2d_player_damage() -> void:
#	count_damage -= 1
#	print("player_life:", count_damage)
#	pass # Replace with function body.
