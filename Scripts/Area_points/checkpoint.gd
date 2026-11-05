extends Area2D

@export var spawn_marker: Marker2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		var target_position = spawn_marker.global_position if spawn_marker else global_position
		GameManager.set_checkpoint(target_position)
		
		print("Checkpoint ativado na posição: ", target_position)
		
		# CORREÇÃO: Usa set_deferred para evitar o conflito com o sinal de física
		set_deferred("monitoring", false)
