extends Area2D

signal coins
signal  colected

var count_coins = 1

@onready var animationPlayer: AnimationPlayer = $AnimationPlayer
@onready var audioCollected: AudioStreamPlayer2D= $Audio/AudioCollected

func _ready() -> void:
	
	emit_signal('coins', count_coins)
	animationPlayer.play("idle")

func play_sound(stream_player: AudioStreamPlayer2D) -> void:
	# Aplica uma leve variação aleatória de pitch antes de tocar
	stream_player.pitch_scale = randf_range(0.9, 1.1)
	print('toquei')
	stream_player.play()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		emit_signal("colected")
		play_sound(audioCollected)
		queue_free()
		#print('coletou moeda')
	pass # Replace with function body.
	
