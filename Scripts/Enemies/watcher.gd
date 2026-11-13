extends StaticBody2D

@export var bullet_scene: PackedScene
@export var rotation_vel:float
@export var pause_time:float = 1.5

# Ângulos limite da câmera (em graus, convertidos para radianos se necessário, mas podemos usar graus direto)
@export var angle_min: float = -45.0
@export var angle_max: float = 45.0

@onready var pivot: Node2D = $Pivot
@onready var ray_cast: RayCast2D = $Pivot/RayCast2D
@onready var marker2D: Marker2D = $Pivot/Marker2D
@onready var timer: Timer = $Timer

enum State{WATCHING, SHOOTING}

var current_state: State = State.WATCHING
var target_direction = 1.0 # 1 para a direita, -1 para a esquerda
var shooting = false
# Variável para controlar para qual limite a câmera está indo (angle_max ou angle_min)
var current_target_angle: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.wait_time = pause_time
	timer.start()
	# Começa indo em direção ao ângulo máximo
	current_target_angle = angle_max
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
		match current_state:
			State.WATCHING:
				_process_scanning(delta)
				_check_player()
			State.SHOOTING:
				_check_player()
				pass
	
func _process_scanning(delta:float)->void:
	# Converte o ângulo alvo de graus para radianos
	var target_rad = deg_to_rad(current_target_angle)
	
func _check_player():
	if ray_cast.is_colliding():
		var collider = ray_cast.get_collider()
		if collider and collider.is_in_group("Player"):
			if not shooting:
				_start_shooting(collider)
				
func _start_shooting(target:Node2D):
	print('acheeei')

func _on_timer_timeout() -> void:
	pass # Replace with function body.
