extends Area2D

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _on_body_entered(body: Node2D) -> void:
		# Se a bola tiver a função de entrar na água, nós a chamamos
		if body.has_method("inside_water"):
			var shape = collision_shape.shape
			var top_y = global_position.y
			
			if shape is RectangleShape2D:
				# Pega o centro da área menos metade da altura da caixa
				top_y = global_position.y - (shape.size.y / 2) * collision_shape.scale.y
			body.inside_water(top_y)


func _on_body_exited(body: Node2D) -> void:
	if body.has_method("out_water"):
			body.out_water()
