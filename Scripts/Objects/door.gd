extends StaticBody2D

var button1 = false
var button2 = false

#verifica se porta está aberta
var is_opened = false

func Open_Door():
	#print('Button1:', button1,'|Button2:', button2)
	if (button1 and button2 == true):
		is_opened = true
		#desativa o collision sem causar bugs
		$CollisionShape2D.set_deferred("disabled", true)
		collision_layer = 0
		collision_mask = 0
		return

func _on_button_state_button(button_pressed: bool) -> void:
	#se está aberta retorna
	if is_opened:
		return
	button1 = button_pressed
	#print(button1)
	Open_Door()


func _on_button_2_state_button(button_pressed: bool) -> void:
	if is_opened:
		return
	button2 = button_pressed
	#print(button2)
	Open_Door()
