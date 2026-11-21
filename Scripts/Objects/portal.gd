extends Area2D

#variável para verificar o id dos portais
@export var portal_id : int = 0

#variável para imperdir o loop do dele transporte
var portal_is_locked : bool = false

func lock_portal() -> void:
	portal_is_locked = true
	await get_tree().create_timer(0.5).timeout
	portal_is_locked = false
	
