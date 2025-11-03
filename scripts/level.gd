extends Node

var pause_menu_scene = preload("res://scenes/ui/pause_menu.tscn")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		add_child(pause_menu_scene.instantiate())
	 
