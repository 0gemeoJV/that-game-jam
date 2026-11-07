extends Node

var current_checkpoint_position: Vector2 = Vector2.ZERO
var initial_spawn_position: Vector2 = Vector2.ZERO
var has_checkpoint: bool = false
var is_player_dead: bool = false

func set_spawn_position(pos: Vector2) -> void:
	initial_spawn_position = pos

func set_checkpoint(pos: Vector2) -> void:
	current_checkpoint_position = pos
	has_checkpoint = true

func on_player_died() -> void:
	is_player_dead = true

func _reset_enemies_to_initial_state() -> void:
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy.has_method("reset_to_initial_state"):
			enemy.call("reset_to_initial_state")

func respawn_player(player: CharacterBody2D) -> void:
	var respawn_position := current_checkpoint_position if has_checkpoint else initial_spawn_position
	player.call("respawn_at", respawn_position)
	_reset_enemies_to_initial_state()
	is_player_dead = false
	call_deferred("_refresh_enemy_targets_after_respawn")

func _refresh_enemy_targets_after_respawn() -> void:
	await get_tree().physics_frame
	if is_player_dead:
		return

	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy.has_method("refresh_targets_after_respawn"):
			enemy.call("refresh_targets_after_respawn")
