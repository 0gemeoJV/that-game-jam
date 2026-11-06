extends CanvasLayer

@onready var screen: Control = $Screen
@onready var main_menu: VBoxContainer = $Screen/CenterContainer/Content/MainMenu
@onready var credits_page: VBoxContainer = $Screen/CenterContainer/Content/CreditsPage
@onready var controls_page: VBoxContainer = $Screen/CenterContainer/Content/ControlsPage
@onready var start_button: Button = $Screen/CenterContainer/Content/MainMenu/StartButton
@onready var credits_button: Button = $Screen/CenterContainer/Content/MainMenu/CreditsButton
@onready var controls_button: Button = $Screen/CenterContainer/Content/MainMenu/ControlsButton
@onready var credits_back_button: Button = $Screen/CenterContainer/Content/CreditsPage/CreditsBackButton
@onready var controls_back_button: Button = $Screen/CenterContainer/Content/ControlsPage/ControlsBackButton
@onready var audioClick: AudioStreamPlayer2D = $Audio/AudioClick
@onready var audioStart: AudioStreamPlayer2D = $Audio/AudioStart

var is_starting := false

func play_sound(stream_player: AudioStreamPlayer2D) -> void:
	# Aplica uma leve variação aleatória de pitch antes de tocar
	stream_player.pitch_scale = randf_range(0.9, 1.1)
	stream_player.play()

func _ready() -> void:
	get_tree().paused = true
	start_button.pressed.connect(_on_start_pressed)
	credits_button.pressed.connect(_show_credits)
	controls_button.pressed.connect(_show_controls)
	credits_back_button.pressed.connect(_show_main_menu)
	controls_back_button.pressed.connect(_show_main_menu)
	start_button.grab_focus.call_deferred()


func _unhandled_key_input(event: InputEvent) -> void:
	if is_starting or not event.is_action_pressed("ui_cancel"):
		
		return

	if credits_page.visible or controls_page.visible:
		_show_main_menu()
		get_viewport().set_input_as_handled()


func _on_start_pressed() -> void:
	play_sound(audioStart)
	if is_starting:
		return
	is_starting = true
	for button in [start_button, credits_button, controls_button, credits_back_button, controls_back_button]:
		button.disabled = true

	var slide_distance := get_viewport().get_visible_rect().size.x
	var tween := create_tween()
	var slide := tween.tween_property(screen, "position", screen.position + Vector2(-slide_distance, 0), 0.65)
	slide.set_trans(Tween.TRANS_CUBIC)
	slide.set_ease(Tween.EASE_IN)
	await tween.finished

	visible = false
	get_tree().paused = false


func _show_credits() -> void:
	_show_page(credits_page, credits_back_button)
	play_sound(audioClick)


func _show_controls() -> void:
	play_sound(audioClick)
	_show_page(controls_page, controls_back_button)


func _show_page(page: VBoxContainer, back_button: Button) -> void:
	main_menu.hide()
	credits_page.hide()
	controls_page.hide()
	page.show()
	back_button.grab_focus()
	play_sound(audioClick)


func _show_main_menu() -> void:
	credits_page.hide()
	controls_page.hide()
	main_menu.show()
	credits_button.grab_focus()
	play_sound(audioClick)
