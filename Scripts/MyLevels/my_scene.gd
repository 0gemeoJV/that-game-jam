extends Node2D

const EXPLOSION_SCENE = preload("res://prefabs/explosion.tscn")
const EXPLOSION_POOL_SIZE := 8
const ENDING_MESSAGE = "Thanks for playing"
const ENDING_LETTER_INTERVAL = 0.25
const ENDING_ANIMATION_DURATION = 5.0
const ENDING_FADE_DURATION = 2.0

@onready var player := $CharacterBody2D as CharacterBody2D
@onready var camera := $Camera2D as Camera2D

var is_ending := false
var _available_explosions: Array[GPUParticles2D] = []
var _warming_explosions: Array[GPUParticles2D] = []

#var count_damage = 3

func _ready() -> void:
	player.follow_camera(camera)
	_create_explosion_pool()


func _create_explosion_pool() -> void:
	for _index in range(EXPLOSION_POOL_SIZE):
		var explosion := EXPLOSION_SCENE.instantiate() as GPUParticles2D
		add_child(explosion)
		explosion.global_position = player.global_position
		explosion.modulate.a = 0.0
		explosion.process_mode = Node.PROCESS_MODE_ALWAYS
		explosion.finished.connect(_on_explosion_finished.bind(explosion))
		_available_explosions.append(explosion)
		_warming_explosions.append(explosion)
		explosion.emitting = true


func spawn_explosion(world_position: Vector2) -> void:
	var explosion: GPUParticles2D
	if _available_explosions.is_empty():
		explosion = EXPLOSION_SCENE.instantiate() as GPUParticles2D
		add_child(explosion)
		explosion.finished.connect(_on_explosion_finished.bind(explosion))
	else:
		explosion = _available_explosions.pop_back()
		_warming_explosions.erase(explosion)

	explosion.process_mode = Node.PROCESS_MODE_INHERIT
	explosion.modulate.a = 1.0
	explosion.global_position = world_position
	explosion.emitting = true
	explosion.restart()


func _on_explosion_finished(explosion: GPUParticles2D) -> void:
	if _warming_explosions.has(explosion):
		_warming_explosions.erase(explosion)
		explosion.modulate.a = 1.0
		explosion.process_mode = Node.PROCESS_MODE_INHERIT
		return

	explosion.emitting = false
	if not _available_explosions.has(explosion):
		_available_explosions.append(explosion)


func _on_final_goal_next_stage() -> void:
	if is_ending or not player.prepare_for_ending():
		return
	is_ending = true
	MusicManager.play_ending()

	var ending_canvas := CanvasLayer.new()
	ending_canvas.layer = 10
	add_child(ending_canvas)

	var message_label := Label.new()
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	message_label.add_theme_font_size_override("font_size", 48)
	message_label.size = Vector2(800, 80)
	ending_canvas.add_child(message_label)

	var fade_rect := ColorRect.new()
	fade_rect.color = Color(0, 0, 0, 0)
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_rect.z_index = 1
	ending_canvas.add_child(fade_rect)
	fade_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	for character_index in range(ENDING_MESSAGE.length()):
		_update_ending_label_position(message_label)
		message_label.text += ENDING_MESSAGE.substr(character_index, 1)
		if character_index < ENDING_MESSAGE.length() - 1:
			var elapsed := 0.0
			while elapsed < ENDING_LETTER_INTERVAL:
				await get_tree().process_frame
				elapsed += get_process_delta_time()
				_update_ending_label_position(message_label)

	await player.play_shutdown_animation(ENDING_ANIMATION_DURATION)

	var fade_tween := create_tween()
	fade_tween.tween_property(fade_rect, "color", Color(0, 0, 0, 1), ENDING_FADE_DURATION)
	await fade_tween.finished


func _update_ending_label_position(label: Label) -> void:
	var player_screen_position := get_viewport().get_canvas_transform() * player.global_position
	label.position = player_screen_position - Vector2(label.size.x / 2.0, 125)


#func _on_character_body_2d_player_damage() -> void:
#	count_damage -= 1
#	print("player_life:", count_damage)
#	pass # Replace with function body.
