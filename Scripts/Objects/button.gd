extends Area2D

# Variável para verificar se o botão está apertado
var pressed = false
@onready var animation = $AnimationPlayer

# Sinal para ativar a porta
signal state_button(button_pressed: bool)

func _ready() -> void:	
	animation.play("idle_button")

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") or body.name == "bullets":
		pressed = true
		emit_signal("state_button", pressed)

func _on_body_exited(body: Node2D) -> void:
	# Verificamos se quem saiu foi o Player ou a bola
	if body.is_in_group("Player") or body.name == "bullets":
		
		# Pega todos os corpos que AINDA estão dentro da Area2D
		var corpos_restantes = get_overlapping_bodies()
		var ainda_tem_objeto_valido = false
		
		# Checa se sobrou algum Player ou bola em cima do botão
		for outro_corpo in corpos_restantes:
			if outro_corpo.is_in_group("Player") or outro_corpo.name == "bullets":
				ainda_tem_objeto_valido = true
				break # Encontrou um, já pode parar de procurar
		
		# Se ainda houver algo válido em cima, continua true. Se não, vira falso.
		if ainda_tem_objeto_valido:
			pressed = true
			#print("Alguém saiu, mas ainda tem algo em cima do botão.")
		else:
			pressed = false
			#print("Botão completamente livre.")
			
		emit_signal("state_button", pressed)
