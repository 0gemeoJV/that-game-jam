extends StaticBody2D

var value_coins: int
var count_coins = 0

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var state_machine = animation_tree.get("parameters/playback")

func _ready() -> void:
	_on_coins_coins(value_coins)
	animation()
	pass
	
func animation():
	if count_coins < 1:
		state_machine.travel("opening")
	if count_coins == 1:
		state_machine.travel("1")
	elif count_coins == 2:
		state_machine.travel("2")
	elif count_coins == 3:
		state_machine.travel("3")
	elif count_coins == 4:
		state_machine.travel("4")
	elif count_coins == 5:
		state_machine.travel("5")
	print(count_coins)


func _on_coins_coins(coins: int) -> void:
	print(count_coins)
	count_coins += coins
	
	pass # Replace with function body.


#func _on_coins_2_coins(coins: int) -> void:
#	print(count_coins)
#	count_coins += coins
#	pass # Replace with function body.


func _on_coins_colected() -> void:
	count_coins -= 1
	if count_coins < 1:
		collision.set_deferred("disabled", true)
	animation()
	pass # Replace with function body.
