extends Node2D

func _ready():
	$Area2D.body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player"):
		print("Food eaten!")
		if body.has_method("grow"):
			body.grow()
		queue_free()
