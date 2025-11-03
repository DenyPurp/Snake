extends Area2D

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player"):
		print("Игрок коснулся стены смерти!")
		body.game_over()
