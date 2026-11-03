extends StaticBody2D

var button1 = false
var button2 = false

@onready var animation_tree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")

#verifica se porta está aberta
var is_opened = false

func _ready() -> void:
	state_machine.travel("door_closed")	
	
func Open_Door():
	
	if  (button1 == false and button2 == false):
		state_machine.travel("door_closed")
	elif(button1 == true and button2 == false):
		state_machine.travel("upper_red")
		print('entrei aki')
	elif (button1 == false and button2 == true):
		#print('Entrei aki')
		print('Button1:', button1,'|Button2:', button2)
		state_machine.travel("upper_green")
	elif (button1 and button2 == true):
		is_opened = true
		#desativa o collision sem causar bugs
		$CollisionShape2D.set_deferred("disabled", true)
		state_machine.travel("door_opened")
		collision_layer = 0
		collision_mask = 0
		return

func _on_button_state_button(button_pressed: bool) -> void:
	#se está aberta retorna
	if is_opened:
		return
	button1 = button_pressed
		##print(button1)
	Open_Door()


func _on_button_2_state_button(button_pressed: bool) -> void:
	if is_opened:
		return
	button2 = button_pressed
	#print(button2)
	Open_Door()
