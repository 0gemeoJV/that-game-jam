extends Area2D

signal coins
signal colected

var count_coins = 1

@onready var animationPlayer: AnimationPlayer = $AnimationPlayer
@onready var audioCollected: AudioStreamPlayer2D = $Audio/AudioCollected
# Dica: Adicione uma referência para a colisão se já não tiver
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	emit_signal('coins', count_coins)
	animationPlayer.play("idle")

func play_sound(stream_player: AudioStreamPlayer2D) -> void:
	stream_player.pitch_scale = randf_range(0.9, 1.1)
	print('toquei')
	stream_player.play()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		emit_signal("colected")
		play_sound(audioCollected)
		
		# 1. Desativa a colisão para evitar múltiplos triggers
		collision_shape.set_deferred("disabled", true)
		
		# 2. Esconde o visual da moeda (pode usar hide() ou parar a animação e sumir com o sprite)
		hide() 
		
		# 3. Espera o áudio terminar de tocar antes de destruir a moeda da memória
		await audioCollected.finished
		queue_free()
