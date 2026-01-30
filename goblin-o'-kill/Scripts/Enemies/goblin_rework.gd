class_name Goblin
extends CharacterBody2D

signal death()

@export_group("Stats")
@export var hp := 10
@export var speed := 200
@export var gold := 1
@export var price := 1
@export var debuffs : Dictionary[String, Timer]
@export_subgroup("Combat")
@export var damage := 1
@export var delay : float = 1.0 ## Time between the start of an attack and the hit
@export var cooldown : float = 1.0 ## Time between the end of an attack and the beggining of the next
@export var meleeAttack : bool = true
@export var attack_range : float = 90
@export var attack_size : float = 1.0
@export var goodAim : bool = false
@export var attackIsChild := true
@export var attackScene : PackedScene = preload("res://Scenes/Attacks/punch.tscn")

var hit_count := 0

var player : Player
@export_group("Animations")
@export var hasSimetricAnimation := true
@export var idle : Array[String] = ["idle","top_idle"]
@export var walk : Array[String] = ["walk"] ## Minimun of 4
@export var attack_anim : Array[String] = ["attack1"]
@export var punch_anim : String = "null"
@export var hit_flash_time : float = 0.1
@export var death_particle : GPUParticles2D

@onready var startingSpeed := speed
@onready var anim : AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox : CollisionShape2D = $CollisionShape2D
@onready var hit_flash_timer : Timer = $"Hit Flash Timer"

@export_group("AI")
@export var initial_state : State
var current_state : State
var states : Dictionary = {}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Shader fail safe
	if anim.material == null:
		var shader_material = ShaderMaterial.new()
		shader_material.shader = load("res://Sprites/Shaders/goblin_hit_flash.tres")
		material.resource_local_to_scene = true
	
	player = get_tree().get_first_node_in_group("Player")
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.transitioned.connect(on_state_transition) # To call, use (self,"new_state")
	if initial_state:
		initial_state.enter()
		current_state = initial_state


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	move_and_slide()
	if current_state:
		current_state.update(delta)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)

func on_state_transition(state, new_state_name : String):
	if state != current_state:
		return
	
	var new_state : State = states.get(new_state_name.to_lower())
	if !new_state:
		return
	
	current_state.exit()
	new_state.enter()
	
	current_state = new_state

func receive_damage(dmg):
	if states.has("roll"):
		hit_count += 1
		if hit_count == 3:
			current_state.emit_signal("transitioned",current_state,"roll")
			hit_count = 0
	
	hp -= dmg
	hit_flash_timer.start(hit_flash_time)
	if anim.material:
		anim.material.set_shader_parameter("Enabled", true)
	if hp <= 0:
		player.gold += roundi(gold * (1 + player.gold_gain))
		player.kills += 1
		velocity = Vector2.ZERO
		attackScene = null
		$CollisionShape2D.call_deferred("set_disabled",true)
		anim.hide()
		death_particle.emitting = true
		await get_tree().create_timer(0.6).timeout
		queue_free()

func _on_hit_flash_timer_timeout() -> void:
	anim.material.set_shader_parameter("Enabled", false)

func debuff(debuff_name : String,Stats : Dictionary[StringName, float],DebuffTime : float,Visual = Color.WHITE) -> void:
	if not debuff_name.to_lower() in debuffs.keys():
		var debuff_timer = Timer.new()
		debuff_timer.one_shot = true
		debuff_timer.name = debuff_name.to_lower()
		add_child(debuff_timer)
		debuffs[debuff_name.to_lower()] = debuff_timer
		debuff_timer.connect("timeout", Callable(on_debuff_end).bind(debuff_name, Stats))
		debuff_timer.start(DebuffTime)
		
		modulate = Visual
		for stat in Stats.keys():
			var modified_stat = get(stat) # Retrieve the variable to change
			set(stat, modified_stat - Stats[stat]) # Set that variable the original minus the debuff
	else:
		debuffs[debuff_name.to_lower()].start()

func on_debuff_end(debuff_name : String, Stats : Dictionary[StringName, float]):
	modulate = Color.WHITE
	for stat in Stats.keys():
		var modified_stat = get(stat) # Retrieve the variable to change
		set(stat, modified_stat + Stats[stat]) # Set that variable the original PLUS the debuff to recover
	debuffs.erase(debuff_name.to_lower())
