extends Control

func _on_music_volume_slider_value_changed(value: float) -> void:
	$"PanelContainer/MarginContainer/VBoxContainer/Music Volume/Music Volume Number".text = var_to_str(int(value * 100))
	AudioServer.set_bus_volume_db(1, linear_to_db(value))

func _on_sfx_volume_slider_value_changed(value: float) -> void:
	$"PanelContainer/MarginContainer/VBoxContainer/SFX Volume/SFX Volume Number".text = var_to_str(int(value * 100))
	AudioServer.set_bus_volume_db(2, linear_to_db(value))

func _on_check_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_master_volume_slider_value_changed(value: float) -> void:
	$"PanelContainer/MarginContainer/VBoxContainer/Master Volume/Master Volume Number".text = var_to_str(int(value * 100))
	AudioServer.set_bus_volume_db(0, linear_to_db(value))

func _on_visibility_changed() -> void:
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		$PanelContainer/MarginContainer/VBoxContainer/CheckButton.button_pressed = true
	else:
		$PanelContainer/MarginContainer/VBoxContainer/CheckButton.button_pressed = false
	$"PanelContainer/MarginContainer/VBoxContainer/Master Volume/Master Volume Number".text =\
	var_to_str(round(db_to_linear(AudioServer.get_bus_volume_db(0)) * 100))
	$"PanelContainer/MarginContainer/VBoxContainer/Music Volume/Music Volume Number".text =\
	var_to_str(round(db_to_linear(AudioServer.get_bus_volume_db(1)) * 100))
	$"PanelContainer/MarginContainer/VBoxContainer/SFX Volume/SFX Volume Number".text =\
	var_to_str(round(db_to_linear(AudioServer.get_bus_volume_db(2)) * 100))
	$"PanelContainer/MarginContainer/VBoxContainer/Master Volume/Master Volume Slider".value =\
	db_to_linear(AudioServer.get_bus_volume_db(0))
	$"PanelContainer/MarginContainer/VBoxContainer/Music Volume/Music Volume Slider".value =\
	db_to_linear(AudioServer.get_bus_volume_db(1))
	$"PanelContainer/MarginContainer/VBoxContainer/SFX Volume/SFX Volume Slider".value =\
	db_to_linear(AudioServer.get_bus_volume_db(2))
