# GameOverUI.gd
extends CanvasLayer

@onready var restart_button = $VBoxContainer/Restart
@onready var leave_button = $VBoxContainer/Leave

func _ready():
	restart_button.pressed.connect(_on_restart_pressed)
	leave_button.pressed.connect(_on_leave_pressed)
	hide()  # Сначала скрываем

func show_game_over():
	show()
	# Делаем кнопки активными
	restart_button.grab_focus()

func _on_restart_pressed():
	get_tree().reload_current_scene()

func _on_leave_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
