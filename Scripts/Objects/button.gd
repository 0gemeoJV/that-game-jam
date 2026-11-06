extends Area2D

# Variável para verificar se o botão está apertado
var pressed = false
var somebody: Node2D
@onready var animation = $AnimationPlayer

# Sinal para ativar a porta
signal state_button(button_pressed: bool)

func _ready() -> void:	
	animation.play("idle_button")

func _process(delta: float) -> void:
	# Verifica em tempo real quais corpos estão na área
	var corpos_restantes = get_overlapping_bodies()
	var ainda_tem_objeto_valido = false
	
	for corpo in corpos_restantes:
		# is_instance_valid garante que o objeto ainda existe e não foi excluído (queue_free)
		if is_instance_valid(corpo) and (corpo.is_in_group("Player") or corpo.name == "bullets" or corpo.is_in_group("land_pursuer")):
			ainda_tem_objeto_valido = true
			break
			
	# Se o estado mudou, atualiza a variável e emite o sinal
	if pressed != ainda_tem_objeto_valido:
		pressed = ainda_tem_objeto_valido
		emit_signal("state_button", pressed)

	# Controla a animação
	if pressed == false:
		$AnimationPlayer.play("idle_button")
	else:
		$AnimationPlayer.play("pressed_button")

func _on_body_entered(body: Node2D) -> void:
	somebody = body
	if body.is_in_group("Player") or body.name == "bullets" or body.is_in_group("land_pursuer"):
		pressed = true
		emit_signal("state_button", pressed)
