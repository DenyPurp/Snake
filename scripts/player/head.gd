extends CharacterBody2D

# Скорость движения змейки
var speed: float = 150.0
# Базовая скорость (для сброса после ускорения)
var base_speed: float = 150.0
# Скорость при ускорении
var boost_speed: float = 300.0
# Скорость поворота (в радианах в секунду)
var rotation_speed: float = 5  
# Плавность поворота
var rotation_smoothness: float = 10.0
# Целевой угол поворота
var target_rotation: float = 0.0

# Таймер для эффекта замедления
var slow_timer: Timer
var is_slowed: bool = false
var current_slow_factor: float = 1.0

# Система тела змейки
@export var segment_scene: PackedScene
@export var game_over_ui_scene: PackedScene
@export var pause_ui_scene: PackedScene
@onready var label: Label = %Label

var segments: Array[Node2D] = []
var segment_positions: Array[Vector2] = []
var segment_rotations: Array[float] = []
var segment_distance: float = 20.0
var is_alive: bool = true
var is_boosting: bool = false
var pause_ui_instance: Node = null

var count_circle: int = 0

func _ready():
	add_to_group("player")
	target_rotation = deg_to_rad(0)
	rotation = target_rotation
	
	segment_positions.append(global_position)
	segment_rotations.append(rotation)
	
	# Создаем таймер для эффекта замедления
	slow_timer = Timer.new()
	slow_timer.one_shot = true
	slow_timer.timeout.connect(_on_slow_timer_timeout)
	add_child(slow_timer)
	
	for i in range(3):
		add_segment()

func _physics_process(delta):
	if not is_alive or get_tree().paused:  # Не двигаемся если умер или пауза
		return
		
	handle_input(delta)
	apply_rotation(delta)
	
	# Устанавливаем скорость в зависимости от состояния ускорения и замедления
	var current_speed = speed * current_slow_factor
	var current_boost_speed = boost_speed * current_slow_factor
	
	if is_boosting:
		velocity = transform.x * current_boost_speed
	else:
		velocity = transform.x * current_speed
	move_and_slide()
	
	# ПРОВЕРКА СТЕНЫ
	if get_slide_collision_count() > 0:
		game_over()
	
	update_segments()

# Новый метод для применения эффекта замедления
func apply_slow_effect(slow_factor: float, duration: float):
	current_slow_factor = slow_factor
	is_slowed = true
	
	# Перезапускаем таймер, если эффект уже активен
	if slow_timer.time_left > 0:
		slow_timer.start(duration)
	else:
		slow_timer.start(duration)
	
	print("Slow effect applied: speed reduced to ", current_slow_factor * 100, "%")

# Обработчик окончания эффекта замедления
func _on_slow_timer_timeout():
	current_slow_factor = 1.0
	is_slowed = false
	print("Slow effect ended: speed returned to normal")

func handle_boost():
	# Ускорение при зажатии пробела
	if Input.is_action_pressed("ui_accept"):
		if not is_boosting:
			is_boosting = true
	else:
		if is_boosting:
			is_boosting = false

func game_over():
	if not is_alive:
		return
	
	is_alive = false
	velocity = Vector2.ZERO
	
	if game_over_ui_scene:
		var game_over_ui = game_over_ui_scene.instantiate()
		get_tree().current_scene.add_child(game_over_ui)
		game_over_ui.show_game_over()

func handle_input(delta):
	if not is_alive or get_tree().paused:
		return
	
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		target_rotation -= rotation_speed * delta
	elif Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		target_rotation += rotation_speed * delta

	handle_boost()
	
func apply_rotation(delta):
	rotation = lerp_angle(rotation, target_rotation, rotation_smoothness * delta)

func add_segment():
	if segment_scene == null:
		return
	
	var new_segment = segment_scene.instantiate() as Node2D
	get_parent().add_child.call_deferred(new_segment)
	segments.append(new_segment)
	
	if segments.size() == 1:
		new_segment.global_position = global_position - transform.x * segment_distance
		new_segment.rotation = rotation
	else:
		var last_segment = segments[segments.size() - 2]
		new_segment.global_position = last_segment.global_position
		new_segment.rotation = last_segment.rotation
	
	segment_positions.append(new_segment.global_position)
	segment_rotations.append(new_segment.rotation)

func update_position_history():
	segment_positions.push_front(global_position)
	segment_rotations.push_front(rotation)
	
	if segment_positions.size() > segments.size() * 10 + 10:
		segment_positions.pop_back()
		segment_rotations.pop_back()

func update_segments():
	update_position_history()
	
	for i in range(segments.size()):
		var segment = segments[i]
		var target_index = (i + 1.3) * 5
		
		if target_index < segment_positions.size():
			segment.global_position = segment_positions[target_index]
			segment.rotation = segment_rotations[target_index]

func grow():
	add_segment()
	
func set_circle(new_count_circle : int) -> void:
	count_circle = new_count_circle
	label.text = "Круги: " + str(count_circle)

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("line"):
		set_circle(count_circle+1)

#jjdjdjd
