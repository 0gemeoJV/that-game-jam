extends StaticBody2D

var value_coins: int
var count_coins = 0

func _ready() -> void:
	_on_coins_coins(value_coins)
	pass
	


func _on_coins_coins(coins: int) -> void:
	print(count_coins)
	count_coins += coins
	pass # Replace with function body.


func _on_coins_2_coins(coins: int) -> void:
	print(count_coins)
	count_coins += coins
	pass # Replace with function body.
