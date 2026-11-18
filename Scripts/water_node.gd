extends Node2D
class_name water

var water_size: Vector2 = Vector2.ZERO
@export_range(0.0, 1.0) var surface_pos_y: float = 0.0 # 0.0 faz a superfície começar no topo exato da área
@export_range(2, 512) var segment_count: int = 64

@export var player_splash_multiplier: float = 0.12
@export_range(0.0, 1000.0) var water_physics_speed: float = 80.0
@export var water_restoring_force: float = 0.2
@export var wave_energy_loss: float = 0.04
@export var wave_strength: float = 0.25
@export_range(1, 64) var wave_spread_updates: int = 8

@export_range(1.0, 32.0, 1.0) var pixel_size: float = 2.0 # Tamanho do "pixel" da água
@export_range(1, 8) var surface_pixel_rows: int = 1 # Espessura da linha da superfície em pixels
@export var surface_color: Color = Color("8ed3dca9", 0.8)
@export var water_fill_color: Color = Color("37b0c5a9", 0.5)



var segment_data: PackedFloat32Array = PackedFloat32Array()
var segment_velocities: PackedFloat32Array = PackedFloat32Array()
var water_area: Area2D
var source_collision_shape: CollisionShape2D

func _ready() -> void:
	source_collision_shape = get_parent() as CollisionShape2D
	if source_collision_shape == null:
		push_error("WaterNode must be a child of a CollisionShape2D.")
		set_physics_process(false)
		return

	var rectangle_shape := source_collision_shape.shape as RectangleShape2D
	if rectangle_shape == null:
		push_error("WaterNode requires its parent CollisionShape2D to use a RectangleShape2D.")
		set_physics_process(false)
		return

	water_size = rectangle_shape.size
	_initialize_surface()
	_create_water_area()
	queue_redraw()

func _initialize_surface() -> void:
	var count := maxi(2, segment_count)
	segment_data.resize(count)
	segment_velocities.resize(count)

func _create_water_area() -> void:
	water_area = Area2D.new()
	water_area.name = "WaterArea"
	water_area.collision_layer = 0
	water_area.collision_mask = 0xFFFFFFFF
	add_child(water_area)
	water_area.body_entered.connect(_on_body_entered)

	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(absf(water_size.x), absf(water_size.y))
	collision.shape = shape
	water_area.add_child(collision)

func _physics_process(delta: float) -> void:
	if segment_data.size() < 2:
		return

	var width := maxf(absf(water_size.x), 1.0)
	var spacing := width / float(segment_data.size() - 1)
	var speed := maxf(water_physics_speed, 0.0)
	var restoring_force := maxf(water_restoring_force, 0.0) * 3600.0
	var substeps := maxi(1, wave_spread_updates)
	var sub_delta := delta / float(substeps)
	var damping := pow(clampf(1.0 - wave_energy_loss, 0.0, 1.0), sub_delta * 60.0)

	for _step in range(substeps):
		var updated_heights: PackedFloat32Array = segment_data.duplicate()
		var courant := speed * sub_delta / spacing
		var wave_coefficient := minf(courant * courant, 0.5)
		for i in range(segment_data.size()):
			var height := segment_data[i]
			var left_height := segment_data[i - 1] if i > 0 else height
			var right_height := segment_data[i + 1] if i < segment_data.size() - 1 else height
			var acceleration := (
				(left_height + right_height - 2.0 * height) * wave_coefficient / (sub_delta * sub_delta)
				- height * restoring_force
			)
			segment_velocities[i] = (segment_velocities[i] + acceleration * sub_delta) * damping
			updated_heights[i] = clampf(
				height + segment_velocities[i] * sub_delta,
				-absf(water_size.y) * 0.25,
				absf(water_size.y) * 0.25
			)
		segment_data = updated_heights

	queue_redraw()

# --- FUNÇÃO _DRAW REFEITA PARA PIXEL ART ---
func _draw() -> void:
	if segment_data.size() < 2:
		return

	var width := absf(water_size.x)
	var height := absf(water_size.y)
	var px := maxf(pixel_size, 1.0)
	
	# Alinha as bordas iniciais à grade de pixels
	var left := snappedf(-width * 0.5, px)
	var bottom := snappedf(height * 0.5, px)
	var base_y := -height * 0.5 + clampf(surface_pos_y, 0.0, 1.0) * height
	
	var column_count := maxi(1, int(ceil(width / px)))
	var surface_thickness := px * float(surface_pixel_rows)

	for col in range(column_count):
		var col_x := left + float(col) * px
		# Garante que a última coluna não ultrapasse a largura da caixa
		var col_width := minf(px, (left + width) - col_x)
		if col_width <= 0.0:
			break

		# Mapeia a coluna atual para o índice correspondente na simulação física
		var progress := (float(col) + 0.5) / float(column_count)
		var exact_index := progress * float(segment_data.size() - 1)
		var idx_low := clampi(int(floor(exact_index)), 0, segment_data.size() - 1)
		var idx_high := clampi(idx_low + 1, 0, segment_data.size() - 1)
		var weight := exact_index - float(idx_low)
		
		# Interpola suavemente a física e depois trava (snap) no pixel mais próximo
		var wave_offset := lerpf(segment_data[idx_low], segment_data[idx_high], weight)
		var snapped_top_y := snappedf(base_y + wave_offset, px)
		
		# Limita para não vazar fora da caixa de colisão
		snapped_top_y = clampf(snapped_top_y, -height * 0.5, bottom - surface_thickness)

		# 1. Desenha a espuma/superfície em degraus
		var surface_rect := Rect2(col_x, snapped_top_y, col_width, surface_thickness)
		draw_rect(surface_rect, surface_color, true)

		# 2. Desenha o corpo da água abaixo da espuma
		var body_top_y := snapped_top_y + surface_thickness
		var body_height := bottom - body_top_y
		if body_height > 0.0:
			var body_rect := Rect2(col_x, body_top_y, col_width, body_height)
			draw_rect(body_rect, water_fill_color, true)

func _on_body_entered(body: Node2D) -> void:
	var local_x := to_local(body.global_position).x
	var width := maxf(absf(water_size.x), 1.0)
	var segment_index := clampi(
		roundi((local_x + width * 0.5) / width * float(segment_data.size() - 1)),
		0,
		segment_data.size() - 1
	)

	var vertical_speed := 0.0
	if body is CharacterBody2D:
		vertical_speed = body.velocity.y
	elif body is RigidBody2D:
		vertical_speed = body.linear_velocity.y

	var impact_direction := signf(vertical_speed)
	if impact_direction == 0.0:
		impact_direction = 1.0
	var impact_size := maxf(2.0, absf(vertical_speed) * maxf(player_splash_multiplier, 0.0))
	impact_size *= maxf(wave_strength, 0.0)
	impact_size = minf(impact_size, minf(absf(water_size.y) * 0.08, 24.0))
	if impact_size > 0.0:
		segment_velocities[segment_index] += impact_direction * impact_size * 60.0
