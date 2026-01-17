extends Area2D

signal interacted(user : Player)

@export_range(1,4) var tip_position = 1

var canInteract : bool = false
var user : Player

var keyPosition : Array[Vector2] = [Vector2(0,-100),Vector2(100,0),Vector2(0,100),Vector2(-100,0)]

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("e") and canInteract:
		emit_signal("interacted", user)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		user = body
		canInteract = true
		user.key_tip.position = keyPosition[tip_position - 1]
		user.key_tip.show()

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		user = body
		canInteract = false
		user.key_tip.hide()
