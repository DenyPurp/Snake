extends Node2D

# Эффект замедления (1.0 = нормальная скорость, 0.5 = вдвое медленнее)
var slow_factor: float = 0.7
# Длительность эффекта замедления в секундах
var slow_duration: float = 3.0

func _ready():
	$Area2D.body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player"):
		print("Food eaten! Player slowed down.")
		if body.has_method("apply_slow_effect"):
			body.apply_slow_effect(slow_factor, slow_duration)
		queue_free()
