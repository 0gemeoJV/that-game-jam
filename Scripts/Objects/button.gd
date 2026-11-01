extends Area2D

#variáveis para verificar se apertou o botao
var pressed = false
#-------------------#
#Sinal para ativar a porta
signal state_button(button_pressed: bool)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") or body.name == "bullets":
		pressed = true
		#print("bola me apertou")
	emit_signal("state_button", pressed)


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player") or body.name == "bullets":
		if(body == null):
			pressed = false
		#print("bola me soltou")
	emit_signal("state_button", pressed)
