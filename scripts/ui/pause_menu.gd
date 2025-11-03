extends CanvasLayer

@onready var panel_container: PanelContainer = $MarginContainer/PanelContainer

var is_closing = false

func _ready() -> void:
	
	panel_container.pivot_offset = panel_container.size / 2 #Это чтобы меню вылетало из центра
	get_tree().paused = true #Пауза
	
	
	var tween = create_tween() #Это анимация вылета меню
	tween.tween_property(panel_container, "scale", Vector2.ZERO, 0)
	tween.tween_property(panel_container, "scale", Vector2.ONE, .3)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	
func close(): #функция закрытия паузы
	if is_closing: #эта строчка убирает многократные нажатия (не особо заметно кста)
		return
	
	is_closing = true
	
	var tween = create_tween() #Это анимация возвращению в игру (обратка)
	tween.tween_property(panel_container, "scale", Vector2.ONE, 0)
	tween.tween_property(panel_container, "scale", Vector2.ZERO, .3)\
	.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	
	await tween.finished
	get_tree().paused = false
	queue_free()

func _input(event: InputEvent) -> void: #функция для закрытия на кнопку esc
	if event.is_action_pressed("pause"):
		close()

func _on_resume_pressed() -> void: #функция для закрытия на кнопку resume
	close()


func _on_options_pressed() -> void:
	pass # Replace with function body.


func _on_quit_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
