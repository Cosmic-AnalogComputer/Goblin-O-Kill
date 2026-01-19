extends Area2D

signal interacted(user : Player)

@export_range(1,4) var tip_position = 1
@export var distance = 100
@export var scale_bonus : float = 4

@onready var key_tip = $Key

var canInteract : bool = false
var user : Player

var keyPosition : Array[Vector2] = [Vector2(0,-1),Vector2(1,0),Vector2(0,1),Vector2(-1,0)]

func _ready() -> void:
	key_tip.scale = Vector2(scale_bonus,scale_bonus)

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("e") and canInteract:
		emit_signal("interacted", user)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		canInteract = true
		key_tip.position = keyPosition[tip_position - 1] * distance
		key_tip.show()

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		user = body
		canInteract = false
		key_tip.hide()
