extends Area2D

signal life_charge

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		emit_signal('life_charge')
		print('Fui tocado')
	pass # Replace with function body.
