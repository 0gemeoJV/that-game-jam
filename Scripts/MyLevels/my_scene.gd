extends Node2D

@onready var player := $CharacterBody2D as CharacterBody2D
@onready var camera := $Camera2D as Camera2D

func _ready() -> void:
	player.follow_camera(camera)
