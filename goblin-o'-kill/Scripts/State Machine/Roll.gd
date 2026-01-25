class_name RollingState
extends State

var direction : Vector2
@export var rollTime := 0.75
@onready var default_rollTime = rollTime

func enter():
	enemy.z_index = -1
	rollTime = default_rollTime
	if randf() < 0.5:
		direction = enemy.position - target.global_position
	else:
		direction = target.global_position - enemy.position
	
	enemy.scale = Vector2(1.1,1.1)
	enemy.velocity = direction.normalized() * 300
	enemy.set_collision_layer_value(3, false)
	if direction.x > 0:
		enemy.anim.play("right_roll")
	else:
		enemy.anim.play("left_roll")

func update(delta : float):
	if rollTime > 0.0:
		rollTime -= delta
	else:
		emit_signal("transitioned", self, "chase")

func exit():
	enemy.z_index = 0
	enemy.scale = Vector2(1,1)
	enemy.velocity = Vector2.ZERO
	enemy.set_collision_layer_value(3, true)
