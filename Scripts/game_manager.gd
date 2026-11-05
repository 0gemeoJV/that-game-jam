extends Node

var current_checkpoint_position: Vector2 = Vector2.ZERO
var initial_spawn_position: Vector2 = Vector2.ZERO
var has_checkpoint: bool = false

func set_spawn_position(pos: Vector2) -> void:
	initial_spawn_position = pos

func set_checkpoint(pos: Vector2) -> void:
	current_checkpoint_position = pos
	has_checkpoint = true

func respawn_player(player: CharacterBody2D) -> void:
	var respawn_position := current_checkpoint_position if has_checkpoint else initial_spawn_position
	player.call("respawn_at", respawn_position)
