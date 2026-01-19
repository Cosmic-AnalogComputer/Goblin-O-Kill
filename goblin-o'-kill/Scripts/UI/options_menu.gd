extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_music_volume_slider_value_changed(value: float) -> void:
	$"PanelContainer/MarginContainer/VBoxContainer/Music Volume/Music Volume Number".text = var_to_str(value * 100)
	AudioServer.set_bus_volume_db(1, linear_to_db(value))

func _on_sfx_volume_slider_value_changed(value: float) -> void:
	$"PanelContainer/MarginContainer/VBoxContainer/SFX Volume/SFX Volume Number".text = var_to_str(value * 100)
	AudioServer.set_bus_volume_db(2, linear_to_db(value))

func _on_check_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
