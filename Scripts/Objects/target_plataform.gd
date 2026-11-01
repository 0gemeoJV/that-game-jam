extends StaticBody2D


func _on_area_collision_body_entered(body: Node2D) -> void:
	if body.name == "bullets":
		print('Toca a animação de virar plataforma')
	pass # Replace with function body.
