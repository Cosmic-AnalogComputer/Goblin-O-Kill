extends Control

@onready var pause_menu = $PanelContainer
@onready var options_menu = $"Options Menu"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("escape") and !get_tree().paused:
		pause()
	elif Input.is_action_just_pressed("escape") and get_tree().paused:
		resume()

func resume():
	toggle(false)
	hide()
	get_tree().paused = false

func pause():
	show()
	get_tree().paused = true

func _on_resume_button_down() -> void:
	resume()

func _on_quit_button_down() -> void:
	get_tree().paused = false
	GlobalVariables.save_record()
	get_tree().change_scene_to_file("res://Scenes/UI/main_menu.tscn")

func _on_options_button_down() -> void:
	toggle(true)

func _on_back_button_pressed() -> void:
	toggle(false)

func toggle(show_options : bool):
	pause_menu.visible = !show_options
	options_menu.visible = show_options
