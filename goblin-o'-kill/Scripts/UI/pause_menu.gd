extends Control

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("escape") and !get_tree().paused:
		pause()
	elif Input.is_action_just_pressed("escape") and get_tree().paused:
		resume()

func resume():
	hide()
	get_tree().paused = false

func pause():
	show()
	get_tree().paused = true

func _on_resume_button_down() -> void:
	resume()

func _on_quit_button_down() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/UI/main_menu.tscn")

func _on_options_button_down() -> void:
	$PanelContainer.hide()
	$"Options Menu".show()

func _on_back_button_pressed() -> void:
	$PanelContainer.show()
	$"Options Menu".hide()

#func _on_visibility_changed() -> void:
#	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
#		$PanelContainer/MarginContainer/VBoxContainer/CheckButton.button_pressed = true
#	else:
#		$PanelContainer/MarginContainer/VBoxContainer/CheckButton.button_pressed = false
