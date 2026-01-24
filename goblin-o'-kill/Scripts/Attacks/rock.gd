extends Node2D

var damage : int
@export var speed = 5
var usage : int

var hit_sounds : Array = ["res://Audios/Hits/Hit1_11k.wav", \
"res://Audios/Hits/Hit1_22k.wav","res://Audios/Hits/Hit1_44k.wav","res://Audios/Hits/Hit2_44k.wav"]

func _ready() -> void:
	var hit_audio = load(hit_sounds.pick_random())
	$Audio.stream = hit_audio

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	position += Vector2.RIGHT.rotated(rotation) * speed
	if $RayCast2D.is_colliding():
		usage += 1
		var collider = $RayCast2D.get_collider()
		if collider is Player and usage == 1:
			collider.receive_damage(damage)
			speed = 0
			$Sprite2D.hide()
			$RayCast2D.enabled = false
			$RayCast2D/GPUParticles2D.emitting = true
			$Audio.play()
			await get_tree().create_timer(1.0).timeout
			queue_free()
		elif not collider is Player:
			speed = 0
			$Sprite2D.hide()
			$RayCast2D.enabled = false
			$RayCast2D/GPUParticles2D.emitting = true
			await get_tree().create_timer(1.0).timeout
			queue_free()
