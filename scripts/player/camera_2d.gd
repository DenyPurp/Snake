# Camera2D скрипт
extends Camera2D

func _ready():
	position_smoothing_speed = 7.0
	
func _process(delta):
	var player = get_tree().get_first_node_in_group("player")
	if player:
		global_position = player.global_position
