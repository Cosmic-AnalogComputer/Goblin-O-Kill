class_name Player
extends CharacterBody2D

enum STATES {IDLE,ROLLING,DEAD,ATTACKING}
var state : STATES = STATES.IDLE

@export_group("Stats")
@export var gold : int = 0
@export var max_hp := 10
@export var hp := 10
@export var gold_gain : float = 1.0
@export_subgroup("Combat")
@export var strength := 1
@export var crit_chance : float = 0.05 ## x 100 on attack
@export var crit_mod : float = 1.5
@export var cooldown : float = 1.0
var too_fast = false
@export var attackScene = preload("res://Scenes/Attacks/punch.tscn")

var rollDirection : Vector2
var idle = "idle"
var walk = "walk"
var currentAttack = 1
var speed = 375
var inmortal = false

@onready var startingSpeed = speed
@onready var hitbox = $CollisionShape2D
@onready var anim = $AnimatedSprite2D

@export_group("UI References")
@export_subgroup("Stats")

@export var hpbar : ProgressBar
@export var hp_text : Label
@export var gold_text : Label
@export var gain_text : Label
@export var dmg_text : Label
@export var attack_speed_text : Label
@export var crit_chance_text : Label
@export var crit_mod_text : Label

@export_subgroup("Other UI")
@export var wave_text : RichTextLabel
@export var game_timer : Label
@export var kill_count : Label
var game_timer_secs := 0:
	set(value):
		if value >= 60:
			game_timer_secs = 0
			game_timer_mins += 1
		else:
			game_timer_secs = value
		if game_timer_mins:
			game_timer.text = var_to_str(game_timer_mins) + ":" + var_to_str(game_timer_secs)
		else:
			game_timer.text = var_to_str(game_timer_secs)
var game_timer_mins := 0

var kills := 0:
	set(value):
		kills = value
		kill_count.text = var_to_str(value)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	updateUI(true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var direction = Input.get_vector("a","d","w","s")
	if direction and state != STATES.ROLLING:
		velocity = direction.normalized() * speed
		if state == STATES.IDLE:
			anim.play(walk)
			if direction.x < 0:
				anim.flip_h = true
			if direction.x > 0:
				anim.flip_h = false
		rollDirection = direction
		
		if direction.y < 0:
			walk = "top_walk"
			idle = "top_idle"
		else:
			walk = "walk"
			idle = "idle"
	elif state != STATES.ROLLING:
		velocity = Vector2.ZERO
		rollDirection = Vector2.ZERO
		if state == STATES.IDLE:
			anim.play(idle)
	
	if Input.is_action_pressed("shift") and state != STATES.ROLLING:
		if rollDirection:
			# Animation
			if state != STATES.IDLE:
				anim.flip_h = !rollDirection.x > 0
			anim.play("roll")
			
			# State
			state = STATES.ROLLING
			velocity = rollDirection.normalized() * startingSpeed
			set_collision_layer_value(2, false)
			set_collision_mask_value(3, false)
			
			# Timings
			$CD.set_paused(true)
			$RollAudio.play()
			$IFrames.start()
	
	move_and_slide()

func _process(delta: float) -> void:
	# ATTACK
	if Input.is_action_pressed("C1") and state == STATES.IDLE:
		attack()
		speed = 300

func _on_i_frames_timeout() -> void:
	set_collision_layer_value(2, true)
	set_collision_mask_value(3, true)
	state = STATES.IDLE
	$CD.set_paused(false)

func receive_damage(dmg):
	if !inmortal:
		hp -= dmg
	if hp <= 0:
		state = STATES.DEAD
		anim.hide()
		
		$"CanvasLayer/Death Menu".show()
		$"CanvasLayer/Death Menu/PanelContainer/MarginContainer/VBoxContainer/Death Text".text =\
		"[p][color=red]YOU DIED[/color][/p][p]At wave: " + var_to_str(GlobalVariables.current_wave)
		GlobalVariables.current_wave = 0
		get_tree().paused = true
	updateUI()

func attack():
	state = STATES.ATTACKING
	$CD.start(cooldown)
	var attack = attackScene.instantiate()
	attack.position = get_local_mouse_position().normalized() * 75
	attack.look_at(get_local_mouse_position() * 75)
	attack.set_collision_mask(4)
	var hurt = get_dmg()
	attack.damage = hurt.x
	if hurt.y == 1.0:
		attack.modulate = Color.DEEP_SKY_BLUE
	anim.play(get_attack_anim())
	add_child(attack)


func _on_cd_timeout() -> void:
	speed = startingSpeed
	state = STATES.IDLE

func get_dmg() -> Vector2:
	var dmg : int
	var crit : bool
	dmg = strength
	if randf() <= crit_chance:
		dmg * crit_mod
		crit = true
	
	return Vector2(dmg,float(crit))

func updateUI(new_wave = false):
	if new_wave:
		wave_text.text = "Wave " + var_to_str(GlobalVariables.current_wave)
	hpbar.max_value = max_hp
	hpbar.value = hp
	hp_text.text = var_to_str(hp) + "/" + var_to_str(max_hp)
	gold_text.text = "$" + var_to_str(gold)
	gain_text.text = var_to_str(roundi(gold_gain * 100)) + "%"
	dmg_text.text = var_to_str(strength)
	if too_fast:
		attack_speed_text.text = "Too fast!"
	else:
		attack_speed_text.text = var_to_str(cooldown) + "s"
	crit_chance_text.text = var_to_str(crit_chance * 100) + "%"
	crit_mod_text.text = "x" + var_to_str(crit_mod)

func _on_world_new_wave() -> void:
	updateUI(true)

func _on_quit_to_desktop_button_down() -> void:
	get_tree().quit()

func _on_restart_button_down() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func get_attack_anim() -> String:
	var rot = int(rad_to_deg(get_angle_to(get_global_mouse_position())) + 90)
	#print(rot)
	if rot in range(0,180):
		anim.flip_h = false
	else:
		anim.flip_h = true
	
	var attack_anim : Array[String] = ["top_attack","attack","attack"]
	var arc = -60
	var arc_2 = 60
	for a in 3:
		if rot in range(arc,arc_2):
			return attack_anim[a]
		else:
			arc = arc_2
			arc_2 += 90
	
	return attack_anim[2]

func _on_sec_timer_timeout() -> void:
	game_timer_secs += 1
