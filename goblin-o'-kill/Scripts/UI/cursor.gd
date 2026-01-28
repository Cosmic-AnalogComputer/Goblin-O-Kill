extends Node

# Huge thanks to Mostly Mad Productions for making a tutorial on this script

const cursor_speed := 500.0
const deadzone := 0.2

func _process(delta: float) -> void:
	#var move = Vector2(
	#	Input.get_joy_axis(0, JOY_AXIS_RIGHT_X),
	#	Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
	#)
	var move = Input.get_vector(
		"right_joy_negative_x",
		"right_joy_positive_x",
		"right_joy_negative_y",
		"right_joy_positive_y"
		)
	
	if move.length() < deadzone:
		move = Vector2.ZERO
	else:
		Input.warp_mouse(get_window().get_mouse_position() + move * cursor_speed * delta)
	
