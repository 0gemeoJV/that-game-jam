extends Node

var current_checkpoint_position: Vector2 = Vector2.ZERO
var has_checkpoint: bool = false

func set_checkpoint(pos: Vector2) -> void:
	current_checkpoint_position = pos
	has_checkpoint = true

func respawn_player(player: CharacterBody2D) -> void:
	if has_checkpoint:
		player.global_position = current_checkpoint_position
	else:
		# Posição inicial padrão da fase se nenhum checkpoint foi pego
		pass
