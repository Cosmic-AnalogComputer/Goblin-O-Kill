class_name Punch
extends Area2D

signal hit(goblin, attack_node)

var hit_smth := false

var damage : int
var crit := false
var crit_chance : float
var crit_mod : float

var attack_particles : Array[ParticleProcessMaterial]

var hit_sounds : Array = ["res://Audios/Hits/Hit1_11k.wav", \
	"res://Audios/Hits/Hit1_22k.wav","res://Audios/Hits/Hit1_44k.wav","res://Audios/Hits/Hit2_44k.wav"]
var play = "slash"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if attack_particles:
		var particle_node = GPUParticles2D.new()
		particle_node.process_material = attack_particles
		particle_node.emitting = true
	
	$Sprite2D.play(play)
	var hit_audio = load(hit_sounds.pick_random())
	$Audio.stream = hit_audio

func _on_body_entered(body: Node2D) -> void:
	emit_signal("hit", body, self)
	hit_smth = true
	$Timer.stop()
	$Audio.play()
	body.receive_damage(damage)
	call_deferred("set_monitoring", false)

func _on_timer_timeout() -> void:
	call_deferred("set_monitoring", false)
	

func _on_audio_finished() -> void:
	if hit_smth:
		queue_free()

func _on_particles_finished() -> void:
	if !hit_smth:
		queue_free()
