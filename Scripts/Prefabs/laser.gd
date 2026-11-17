extends Area2D

@export var speed: float = 700.0
@export var damage: int = 1
@export var ray_length: float = 24.0 # Comprimento do feixe de luz/raio em pixels
@export var ray_thickness: float = 4.0 # Espessura do raio
@export var ray_color: Color = Color("#ff2245") # Vermelho laser vibrante
@export var core_color: Color = Color("#ffffff") # Núcleo branco brilhante do raio

var rotation_angle: float = 0.0
var velocity: Vector2 = Vector2.ZERO

func _ready() -> void:
	# Conecta o sinal de colisão usando a nova sintaxe do Godot 4
	body_entered.connect(_on_body_entered)
	
	# Calcula a direção com base no ângulo recebido da câmera
	rotation = rotation_angle
	velocity = Vector2(cos(rotation_angle), sin(rotation_angle)) * speed
	
	# Auto-destruição de segurança caso erre o alvo (evita acumular na memória)
	await get_tree().create_timer(3.0).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	# Move o projétil linearmente a cada frame
	global_position += velocity * delta

func _draw() -> void:
	# Desenha um raio procedural alinhado na horizontal local (a rotação do nó cuida do ângulo)
	# O último argumento 'false' desativa o antialiasing, mantendo os pixels perfeitamente nítidos
	
	var start_point = Vector2.ZERO
	var end_point = Vector2(-ray_length, 0) # Estica o raio para trás da ponta
	
	# 1. Corpo externo do laser (brilho mais largo)
	draw_line(start_point, end_point, ray_color, ray_thickness, false)
	
	# 2. Núcleo interno do laser (linha mais fina e clara no meio para dar efeito de plasma/energia)
	draw_line(start_point, end_point * 0.8, core_color, ray_thickness * 0.4, false)

func _on_body_entered(body: Node2D) -> void:
	# Verifica se acertou o jogador
	if body.is_in_group("jogador"):
		# Exemplo: se o seu player tiver uma função de dano, chame-a aqui:
		# if body.has_method("take_damage"):
		#     body.take_damage(damage)
		pass
	
	# Destroi o projétil ao colidir com qualquer coisa (paredes ou jogador)
	queue_free()
