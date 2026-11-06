extends Area2D

signal coins
signal  colected(count_coins: int)

var count_coins = 1

func _ready() -> void:
	emit_signal('coins', count_coins)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		emit_signal("colected")
		queue_free()
		#print('coletou moeda')
	pass # Replace with function body.
