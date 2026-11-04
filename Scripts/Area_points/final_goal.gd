extends Area2D

signal next_stage

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		emit_signal('next_stage')
		#print('passou de fase')
	pass # Replace with function body.
