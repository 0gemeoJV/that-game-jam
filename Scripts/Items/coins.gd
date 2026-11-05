extends Area2D

signal  colected

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		emit_signal("colected")
		queue_free()
		#print('coletou moeda')
	pass # Replace with function body.
