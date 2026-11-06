extends Area2D

signal coins
signal  colected

var count_coins = 1

@onready var animationPlayer: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	
	emit_signal('coins', count_coins)
	animationPlayer.play("idle")

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		emit_signal("colected")
		queue_free()
		#print('coletou moeda')
	pass # Replace with function body.
