extends "res://Scripts/Enemies/pursuer.gd"


#variáveis para cuidar do dash
enum DashState { NORMAL, ANTICIPATION, DASHING, RECOVERY }
var current_dash_state: DashState = DashState.NORMAL
@export var dash_speed: float = 600.0
var dash_direction: float = 1.0


func aplicar_movimento(delta: float) -> void:
	match current_dash_state:
		DashState.NORMAL:
			# Usa a movimentação normal herdada do BaseEnemy
			super(delta)
			
		DashState.ANTICIPATION:
			velocity.x = move_toward(velocity.x, 0, ACCELERATION * delta)
			move_and_slide()
			# Aqui ele fica parado preparando o dash
			
		DashState.DASHING:
			# Move em alta velocidade na direção travada, ignorando novos inputs ou flips
			velocity.x = dash_direction * dash_speed
			if is_on_wall():
				# Interrompe o dash se bater na parede
				print('Interrompe o dash e toca animação de recuperação')
			move_and_slide()
			
		DashState.RECOVERY:
			velocity.x = move_toward(velocity.x, 0, ACCELERATION * delta)
			move_and_slide()
			# Aguarda animação de pós-dash acabar para voltar ao NORMAL

func _on_area_dash_body_entered(body: Node2D) -> void:
	if current_dash_state == DashState.NORMAL and body.is_in_group("Player") or body.is_in_group("Ball"):
		dash_anticipation(body)
		#print('animação de aviso de dash')
		#print('E então Dash')
	pass # Replace with function body.

func dash_anticipation(target: Node2D):
	current_dash_state = DashState.ANTICIPATION
	is_chasing = false # Pausa a perseguição normal durante o dash
	
	dash_direction = sign(target.global_position.x - global_position.x)
	if dash_direction != 0:
		animated_sprite.flip_h = dash_direction < 0
		
	# Toca animação de antecipação 
	#state_machine.travel("dash_anticipation") # Substitua pelo nome real da sua animação
	
	await get_tree().create_timer(1).timeout
	
	if current_dash_state == DashState.ANTICIPATION:
		dash()
		#print('Oi')

func dash():
	current_dash_state = DashState.DASHING
	# Toca animação de movimento rápido
	#state_machine.travel("dashing") # Substitua pelo nome real
	
	# Timer de 1 segundo para durar o dash
	await get_tree().create_timer(1).timeout
	
	if current_dash_state ==  DashState.DASHING:
		dash_recover()

func dash_recover():
	current_dash_state = DashState.RECOVERY
	# Toca animação de pós-dash / cansaço
	#state_machine.travel("dash_recovery") # Substitua pelo nome real
	
	# Timer da recuperação
	await get_tree().create_timer(0.5).timeout
	# Retorna ao estado normal e limpa o estado
	if current_dash_state == DashState.RECOVERY:
		current_dash_state = DashState.NORMAL
		is_chasing = true
		escolher_proximo_alvo() # Reavalia se o player ou bola ainda estão na visão
	pass		
