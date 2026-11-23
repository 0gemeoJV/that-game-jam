extends Area2D

signal follow_ball(ball_body: Node2D)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group('Ball'):
		emit_signal('follow_ball', body)
		#print('É a bola')
	pass # Replace with function body.
