extends Area2D

@export var spawn_marker: Marker2D # Arraste o Marker2D aqui no Inspector

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		# Define a posição de respawn no seu GameManager global
		var respawn_pos = spawn_marker.global_position if spawn_marker else global_position
		GameManager.current_checkpoint_position = respawn_pos
		
		# Feedback visual ou sonoro e desativa a área para não repetir
		print("Checkpoint ativado!")
		monitoring = false
		
		# Exemplo: se usar AnimatedSprite2D, mude para a animação "active"
		# $AnimatedSprite2D.play("active")
