extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$"Play Menu/VBoxContainer/Record Wave".text = "Record: " + var_to_str(GlobalVariables.record)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_play_button_down() -> void:
	$"Play Menu".hide()
	$"Difficulty Select".show()
	#get_tree().change_scene_to_file("res://Scenes/Main/world.tscn")

func _on_options_button_down() -> void:
	$"Play Menu".hide()
	$"Credits to Nekka".hide()
	$"Options Menu".show()

func _on_quit_button_down() -> void:
	get_tree().quit()

func _on_back_button_pressed() -> void:
	$"Play Menu".show()
	$"Credits to Nekka".show()
	$"Options Menu".hide()

func _on_button_button_down() -> void:
	OS.shell_open("https://open.spotify.com/intl-es/artist/6DKyviPEmx6sSRlKQlmFPw")

func _on_cosmic_button_down() -> void:
	OS.shell_open("https://www.youtube.com/@CosmicAnalogComputer")

func _on_easy_button_down() -> void:
	GlobalVariables.difficulty = 1
	get_tree().change_scene_to_file("res://Scenes/Main/world.tscn")

func _on_normal_button_down() -> void:
	GlobalVariables.difficulty = 2
	get_tree().change_scene_to_file("res://Scenes/Main/world.tscn")

func _on_hard_button_down() -> void:
	GlobalVariables.difficulty = 3
	get_tree().change_scene_to_file("res://Scenes/Main/world.tscn")

func _on_back_difficulty_button_down() -> void:
	$"Play Menu".show()
	$"Difficulty Select".hide()
