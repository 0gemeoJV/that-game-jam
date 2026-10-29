extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("bola"):
		# Se a bola tiver a função de entrar na água, nós a chamamos
		if body.has_method("entrar_na_agua"):
			body.inside_water()


func _on_body_exited(body: Node2D) -> void:
	if body.has_method("sair_na_agua"):
			body.out_water()
