extends Node

@export var food: PackedScene
@export var slow_food: PackedScene  # Сцена замедленного яблока
@export var spawn_points: Array[Marker2D] = []
@export var max_food_on_scene: int = 10  # Максимальное количество яблок
@export var min_distance_between_food: float = 30.0  # Минимальное расстояние между яблоками

func _ready():
	# Если точки не назначены вручную - найти автоматически
	if spawn_points.is_empty():
		find_spawn_points()
	
	validate_spawn_points()

func find_spawn_points():
	# Ищем Marker2D по группе
	var markers = get_tree().get_nodes_in_group("spawn_points")
	for marker in markers:
		if marker is Marker2D:
			spawn_points.append(marker)

func validate_spawn_points():
	spawn_points = spawn_points.filter(func(point): return point != null)

func _on_timer_timeout():
	# Проверяем количество яблок на сцене
	if get_food_count() >= max_food_on_scene:
		return
	
	if spawn_points.is_empty():
		return
	
	# Получаем список всех существующих яблок
	var existing_food = get_all_food_nodes()
	
	# Пытаемся найти валидную позицию для спавна
	var valid_position_found = false
	var attempts = 0
	var max_attempts = 20  # Максимальное количество попыток найти валидную позицию
	
	while not valid_position_found and attempts < max_attempts:
		attempts += 1
		
		# Выбираем случайную точку спавна
		var random_point = spawn_points[randi() % spawn_points.size()]
		var candidate_position = random_point.global_position
		
		# Проверяем, нет ли яблок слишком близко к этой позиции
		if is_position_valid(candidate_position, existing_food):
			valid_position_found = true
			
			# Определяем тип яблока (80% обычное, 20% замедленное)
			var food_instance
			var random_value = randf()  # Случайное число от 0.0 до 1.0
			
			if random_value < 0.8:  # 80% шанс
				if food != null:
					food_instance = food.instantiate()
					print("Создано обычное яблоко")
				else:
					push_error("Food scene is not assigned!")
					return
			else:  # 20% шанс
				if slow_food != null:
					food_instance = slow_food.instantiate()
					print("Создано замедленное яблоко")
				else:
					# Если замедленное яблоко не назначено, создаем обычное
					if food != null:
						food_instance = food.instantiate()
						print("Создано обычное яблоко (замедленное не назначено)")
					else:
						push_error("Neither food nor slow_food scenes are assigned!")
						return
			
			# Добавляем яблоко на сцену
			get_tree().current_scene.add_child(food_instance)
			food_instance.global_position = candidate_position
			print("Яблоко создано на позиции: ", candidate_position)
			break
	
	if not valid_position_found:
		print("Не удалось найти валидную позицию для спавна яблока после ", attempts, " попыток")

# Проверяет, можно ли спавнить яблоко на указанной позиции
func is_position_valid(position: Vector2, existing_food: Array) -> bool:
	# Если яблок нет, позиция всегда валидна
	if existing_food.is_empty():
		return true
	
	# Проверяем расстояние до каждого существующего яблока
	for food_node in existing_food:
		if food_node != null and is_instance_valid(food_node):
			var distance = position.distance_to(food_node.global_position)
			if distance < min_distance_between_food:
				return false
	
	return true

# Получает все существующие яблоки на сцене
func get_all_food_nodes() -> Array:
	var all_food = []
	
	# Добавляем обычные яблоки
	var food_nodes = get_tree().get_nodes_in_group("food")
	for node in food_nodes:
		if node != null and is_instance_valid(node):
			all_food.append(node)
	
	# Добавляем замедленные яблоки
	var slow_food_nodes = get_tree().get_nodes_in_group("slow_food")
	for node in slow_food_nodes:
		if node != null and is_instance_valid(node):
			all_food.append(node)
	
	return all_food

# Функция для подсчета яблок на сцене
func get_food_count() -> int:
	var food_count = 0
	var food_nodes = get_tree().get_nodes_in_group("food")  # Обычные яблоки в группе "food"
	var slow_food_nodes = get_tree().get_nodes_in_group("slow_food")  # Замедленные яблоки в группе "slow_food"
	
	for node in food_nodes:
		if node != null and is_instance_valid(node):
			food_count += 1
	
	for node in slow_food_nodes:
		if node != null and is_instance_valid(node):
			food_count += 1
	
	return food_count
