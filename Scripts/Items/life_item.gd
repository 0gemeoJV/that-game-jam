extends Area2D

@onready var animation = $AnimationPlayer


func _ready() -> void:
	animation.speed_scale = 2
	animation.play("life_item")

signal life_charge

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		emit_signal('life_charge')
		queue_free()
	pass # Replace with function body.
