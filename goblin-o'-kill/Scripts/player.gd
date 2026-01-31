class_name Player
extends CharacterBody2D

signal damaged(dmg)
signal just_attacked(attack : Punch)
signal purchase(gold : int)

enum STATES {IDLE,ROLLING,DEAD,ATTACKING}
var state : STATES = STATES.IDLE
var gold_tween : Tween

@export_group("Stats")
@export var strategy_upgrades : Dictionary[GDScript, int] ## GDScript defining upgrade and level
@export var instantiated_upgrades : Dictionary[String, InstantiatedUpgrade] ## Upgrade name and Upgrade Node

@export var gold : int = 0:
	set(value):
		if value > gold:
			gold = value
			if gold_tween:
				gold_tween.kill()
			gold_tween = create_tween().set_ease(Tween.EASE_OUT)
			gold_tween.tween_property(self, "animated_gold", gold, 0.5)
		else:
			emit_signal("purchase", gold)
			gold = value # No tween - Purchase
			animated_gold = gold
			#gold_text.text = "$" + var_to_str(gold)
var animated_gold : int:
	set(value):
		animated_gold = value
		gold_text.text = "$" + var_to_str(animated_gold)
@export var max_hp := 10:
	set(value):
		max_hp = value
		hpbar.max_value = max_hp
		if hp > max_hp:
			hp = clampi(hp,0,max_hp)
@export var hp := 10:
	set(value):
		hp = clampi(value,0,max_hp)
		hp_text.text = var_to_str(hp) + "/" + var_to_str(max_hp)
		hpbar.value = hp
@export var hp_regen := 3.0:
	set(value):
		hp_regen = value
		if hp_regen < 0.0:
			hp_regen = 0.0
		health_regen_text.text = var_to_str(hp_regen) + "s"
		health_regen_timer.wait_time = hp_regen
@export var gold_gain : float = 0.0:
	set(value):
		gold_gain = value
		gain_text.text = "[i]" + var_to_str(roundi(gold_gain * 100)) + "% [/i]"
@export_subgroup("Combat")
@export var strength := 1:
	set(value):
		strength = value
		dmg_text.text = var_to_str(strength)
@export var crit_chance : float = 0.1:
	set(value):
		crit_chance = value
		if crit_chance < 1.0:
			crit_chance = value
			crit_chance_text.text = var_to_str(crit_chance * 100) + "%"
		else:
			crit_chance = 1.0
			crit_chance_text.text = "MAX"
@export var crit_mod : float = 1.5:
	set(value):
		crit_mod = value
		crit_mod_text.text = "x" + var_to_str(crit_mod)
@export var cooldown : float = 1.0:
	set(value):
		cooldown = value
		if cooldown <= 0.01:
			cooldown = 0.01
			attack_speed_text.text = "MAX"
		else:
			attack_speed_text.text = var_to_str(cooldown) + "s"
@export var attackScene = preload("res://Scenes/Attacks/punch.tscn")

var rollDirection : Vector2
var idle = "idle"
var walk = "walk"
var currentAttack = 1
var speed = 375
var inmortal = false

@onready var startingSpeed = speed
@onready var hitbox : CollisionShape2D = $CollisionShape2D
@onready var anim : AnimatedSprite2D = $AnimatedSprite2D
@onready var hit_flash_timer : Timer = $"Hit Flash Timer"
@onready var camera : Camera2D = $Camera2D
@onready var camera_shake_noise : FastNoiseLite = FastNoiseLite.new()

@export_group("UI References")
@export_subgroup("Stats")
@export var hpbar : ProgressBar
@export var hp_text : Label
@export var gold_text : Label
@export var gain_text : RichTextLabel
@export var dmg_text : Label
@export var health_regen_text : Label
@export var attack_speed_text : Label
@export var crit_chance_text : Label
@export var crit_mod_text : Label
@export var health_regen_timer : Timer

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
		if game_timer_secs >= 10:
			game_timer.text = var_to_str(game_timer_mins) + ":" + var_to_str(game_timer_secs)
		else:
			game_timer.text = var_to_str(game_timer_mins) + ":0" + var_to_str(game_timer_secs)
var game_timer_mins := 0

var kills := 0:
	set(value):
		kills = value
		kill_count.text = var_to_str(value)

func _ready() -> void:
	gold_text.text = "$" + var_to_str(animated_gold)
	gain_text.text = "[i]" + var_to_str(roundi(gold_gain * 100)) + "% [/i]"
	
	hpbar.max_value = max_hp
	hpbar.value = hp
	hp_text.text = var_to_str(hp) + "/" + var_to_str(max_hp)
	
	dmg_text.text = var_to_str(strength)
	health_regen_text.text = var_to_str(hp_regen) + "s"
	attack_speed_text.text = var_to_str(cooldown) + "s"
	crit_chance_text.text = var_to_str(crit_chance * 100) + "%"
	crit_mod_text.text = "x" + var_to_str(crit_mod)


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
	
	if Input.is_action_pressed("shift") and not state == STATES.ROLLING:
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

func _process(_delta: float) -> void:
	wave_text.text = "Wave " + var_to_str(GlobalVariables.current_wave)
	# ATTACK
	if Input.is_action_pressed("C1") and state == STATES.IDLE:
		attack()
		speed = 300

func _on_i_frames_timeout() -> void:
	set_collision_layer_value(2, true)
	set_collision_mask_value(3, true)
	state = STATES.IDLE
	$CD.set_paused(false)

func receive_damage(dmg, hit_flash = true):
	emit_signal("damaged", dmg)
	if not health_regen_timer.time_left > 0:
		health_regen_timer.start(hp_regen)
	
	hp -= dmg * int(!inmortal)
	if hit_flash:
		anim.material.set_shader_parameter("Enabled", true)
		hit_flash_timer.start()
	if camera:
		var camera_tween = get_tree().create_tween()
		camera_tween.tween_method(camera_shake, 7.5, 0.0, 0.25)
	if hp <= 0:
		state = STATES.DEAD
		anim.hide()
		
		$"CanvasLayer/Death Menu".show()
		$"CanvasLayer/Death Menu/PanelContainer/MarginContainer/VBoxContainer/Death Text".text =\
		"[p][color=red]YOU DIED[/color][/p][p]At wave: " + var_to_str(GlobalVariables.current_wave)
		get_tree().paused = true

func attack():
	state = STATES.ATTACKING
	$CD.start(cooldown)
	var attack_instance = attackScene.instantiate()
	attack_instance.position = get_local_mouse_position().normalized() * 75
	attack_instance.look_at(get_local_mouse_position() * 75)
	attack_instance.set_collision_mask(4)
	attack_instance.damage = strength
	attack_instance.crit_chance = crit_chance
	attack_instance.crit_mod = crit_mod
	anim.play(get_attack_anim())
	for strat in strategy_upgrades.keys():
		strat.apply_upgrade(attack_instance,strategy_upgrades[strat])
	for instance in instantiated_upgrades.keys():
		instantiated_upgrades[instance].on_attack(attack_instance)
	
	add_child(attack_instance)

func _on_cd_timeout() -> void:
	speed = startingSpeed
	state = STATES.IDLE

func _on_quit_to_desktop_button_down() -> void:
	GlobalVariables.save_record()
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

func _on_hit_flash_timer_timeout() -> void:
	anim.material.set_shader_parameter("Enabled", false)

func _on_health_regen_timer_timeout() -> void:
	hp += 1
	if hp < max_hp:
		health_regen_timer.start(hp_regen)

func camera_shake(intensity : float) -> void: # Thanks to: Single-Minded Ryan on YT for this!
	var cameraOffset = camera_shake_noise.get_noise_1d(Time.get_ticks_msec()) * intensity
	camera.offset = Vector2(cameraOffset,cameraOffset)
