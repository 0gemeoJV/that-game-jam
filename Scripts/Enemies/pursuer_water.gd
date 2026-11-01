extends CharacterBody2D
#procurar video aula depois
#@onready var target = $"../CharacterBody2D"
var SPEED = 150 
var is_chasing = false
var player: Node2D = null
var in_water = false
var velocity_y = 0.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_dizzy = false

func _physics_process(delta: float) -> void:
	
	if is_chasing == true and player != null:
		if in_water == true:
			position += (player.position - position) / SPEED
		else:
			position.x += (player.position.x - position.x) / SPEED 
			velocity_y += gravity * delta
			position.y += velocity_y * delta
	else:
		# Se não estiver perseguindo, mas estiver fora da água, a gravidade ainda o puxa para o chão
		if not in_water:
			velocity_y += gravity * delta
			position.y += velocity_y * delta
		else:
			velocity_y = 0.0
		#move_and_slide()

func _on_vision_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		is_chasing = true
		#print("Player")
		player = body
		
func _on_vision_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		is_chasing = false
		#print("Player saiu")
		player = null

func inside_water(_top_y: float) -> void:
	in_water = true
	#velocity_y = 0.0 # Reseta a velocidade de queda ao entrar na água

func out_water() -> void:
	in_water = false
	#velocity_y = 0.0 # Começa a cair do zero quando sai da água

#função de ficar tonto, chamada no bullets linha 31
func dizzy():
	# Evita acumular temporizadores se o inimigo for atingido várias vezes seguidas
	if is_dizzy:
		return
		
	is_dizzy = true
	is_chasing = false # Para de perseguir o player imediatamente
	
	# Opcional: print para depuração
	# print("Inimigo atordoado!")
	
	# Cria um temporizador de 5 segundos
	await get_tree().create_timer(5.0).timeout
	is_chasing = true
	is_dizzy = false
	pass
