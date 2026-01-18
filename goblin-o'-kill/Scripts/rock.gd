extends Node2D

var damage : int
@export var speed = 5
var usage : int

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += Vector2.RIGHT.rotated(rotation) * speed
	if $RayCast2D.is_colliding():
		usage += 1
		var collider = $RayCast2D.get_collider()
		if collider is Player and usage == 1:
			collider.receive_damage(damage)
			speed = 0
			$Sprite2D.hide()
			$RayCast2D.enabled = false
			$GPUParticles2D.emitting = true
			await get_tree().create_timer(1.0).timeout
			queue_free()
		elif not collider is Player:
			speed = 0
			$Sprite2D.hide()
			$RayCast2D.enabled = false
			$GPUParticles2D.emitting = true
			await get_tree().create_timer(1.0).timeout
			queue_free()
