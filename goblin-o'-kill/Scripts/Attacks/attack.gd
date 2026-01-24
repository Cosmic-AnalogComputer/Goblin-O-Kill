class_name Punch
extends Area2D

var damage : int
var hit_sounds : Array = ["res://Audios/Hits/Hit1_11k.wav", \
	"res://Audios/Hits/Hit1_22k.wav","res://Audios/Hits/Hit1_44k.wav","res://Audios/Hits/Hit2_44k.wav"]
var play = "slash"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Sprite2D.play(play)
	var hit_audio = load(hit_sounds.pick_random())
	$Audio.stream = hit_audio

func _on_body_entered(body: Node2D) -> void:
	$Timer.stop()
	$Audio.play()
	body.receive_damage(damage)
	call_deferred("set_monitoring", false)
	await get_tree().create_timer($Audio.stream.get_length()).timeout
	queue_free()

func _on_timer_timeout() -> void:
	queue_free()
