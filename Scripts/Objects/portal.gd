extends Area2D

#variável para verificar o id dos portais
#Os IDs podem ser alterados no inspetor
#Os portais funcionam em pares e para dar certo eles precisam ser
#do mesmo ID. Ex: Portal1(ID = 0)--> Portal2(ID = 0),
#Portal3(ID = 1)--> Portal4(ID = 1)
@export var portal_id : int = 0

#variável para imperdir o loop do dele transporte
var portal_is_locked : bool = false

func lock_portal() -> void:
	portal_is_locked = true
	await get_tree().create_timer(0.5).timeout
	portal_is_locked = false
	
