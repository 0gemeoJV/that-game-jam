extends StaticBody2D

var button1 = false
var button2 = false

func Open_Door():
	print('Button1:', button1,'|Button2:', button2)
	if (button1 and button2 == true):
		print("open")

func _on_button_state_button(button_pressed: bool) -> void:
	button1 = button_pressed
	#print(button1)
	Open_Door()


func _on_button_2_state_button(button_pressed: bool) -> void:
	button2 = button_pressed
	#print(button2)
	Open_Door()
