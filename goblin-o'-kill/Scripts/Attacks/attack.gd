class_name Punch
extends Area2D

signal hit(goblin, attack_node)
signal kill(goblin, attack_node)

@export var hit_audio : AudioStreamPlayer2D
@export var crit_particle : GPUParticles2D
@export var anim : AnimatedSprite2D

var damage : int
var applied_damage : int
var crit := false
var crit_chance : float
var crit_mod : float

var attack_particles : Array[ParticleProcessMaterial]

var hit_sounds : Array = ["res://Audios/Hits/Hit1_11k.wav", \
	"res://Audios/Hits/Hit1_22k.wav","res://Audios/Hits/Hit1_44k.wav","res://Audios/Hits/Hit2_44k.wav"]
var play = "slash"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for particle in attack_particles:
		var particle_node = GPUParticles2D.new()
		particle_node.process_material = particle
		particle_node.emitting = true
		add_child(particle_node)
	
	anim.play(play)
	hit_audio.stream = load(hit_sounds.pick_random())

func _on_body_entered(body: Node2D) -> void:
	applied_damage = damage
	if randf() < crit_chance:
		crit = true
		applied_damage = roundi(damage * crit_mod)
		crit_particle.emitting = true
	
	emit_signal("hit", body, self)
	$Timer.stop()
	if !hit_audio.playing:
		hit_audio.play()
	if body.hp - applied_damage <= 0:
		emit_signal("kill",body, self)
	
	body.receive_damage(applied_damage)
	call_deferred("set_monitoring", false)

func _on_timer_timeout() -> void:
	if !hit_audio.playing:
		queue_free()

func _on_audio_finished() -> void:
	if not crit:
		queue_free()

func _on_crit_particle_finished() -> void:
	queue_free()
