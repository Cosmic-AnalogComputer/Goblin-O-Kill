class_name Player
extends CharacterBody2D

enum STATES {IDLE,ROLLING,DEAD,ATTACKING}
var state : STATES = STATES.IDLE

@export_group("Stats")
var gold = 0
@export var max_hp = 15
@export var hp = 15
@export_subgroup("Combat")
@export var strength = 1
@export var crit_chance : float = 0.10 # x 100
@export var crit_mod : float = 3.0
@export var cooldown : float = 0.5
var too_fast = false
@export var attackScene = preload("res://Scenes/Attacks/punch.tscn")

var rollDirection : Vector2
var idle = "idle"
var walk = "walk"
var attack_anim = "attack"
var currentAttack = 1
var speed = 375


@onready var startingSpeed = speed
@onready var hitbox = $CollisionShape2D
@onready var anim = $AnimatedSprite2D

@onready var key_tip = $AnimatedSprite2D/Sprite2D

#UI References
@onready var hpbar = $CanvasLayer/Control/ProgressBar
@onready var gold_text = $CanvasLayer/Control/Panel/MarginContainer/VBoxContainer/GOLDDD/Label
@onready var dmg_text = $CanvasLayer/Control/Panel/MarginContainer/VBoxContainer/DMG/Label
@onready var attack_speed_text = $CanvasLayer/Control/Panel/MarginContainer/VBoxContainer/dmgspeed/Label
@onready var crit_chance_text = $CanvasLayer/Control/Panel/MarginContainer/VBoxContainer/CritC/Label
@onready var crit_mod_text = $CanvasLayer/Control/Panel/MarginContainer/VBoxContainer/CritM/Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	updateUI(true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var direction = Input.get_vector("a","d","w","s")
	if direction and not state == STATES.ROLLING:
		velocity = direction.normalized() * speed
		if state == STATES.IDLE:
			anim.play(walk)
		rollDirection = direction
		
		if direction.x < 0:
			anim.flip_h = true
		else:
			anim.flip_h = false
		if direction.y < 0:
			walk = "top_walk"
			idle = "top_idle"
			attack_anim = "top_attack"
		else:
			walk = "walk"
			idle = "idle"
			attack_anim = "attack"
	elif state != STATES.ROLLING:
		velocity = Vector2.ZERO
		rollDirection = Vector2.ZERO
		if state == STATES.IDLE:
			anim.play(idle)
	
	if Input.is_action_pressed("shift") and state != STATES.ROLLING:
		if rollDirection:
			state = STATES.ROLLING
			velocity = rollDirection.normalized() * 350
			set_collision_layer_value(2,false)
			anim.play("roll")
			$CD.set_paused(true)
			$RollAudio.play()
			$IFrames.start()
	
	move_and_slide()
	
	# ATTACK
	if Input.is_action_pressed("C1") and state == STATES.IDLE:
		attack()
		speed = 250
	

func _on_i_frames_timeout() -> void:
	set_collision_layer_value(2,true)
	state = STATES.IDLE
	$CD.set_paused(false)

func receive_damage(dmg):
	hp -= dmg
	if hp <= 0:
		state = STATES.DEAD
		queue_free()
	hpbar.value = hp
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
	anim.play(attack_anim)
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
		$CanvasLayer/Control/PanelContainer/RichTextLabel.text = "Wave " + var_to_str(GlobalVariables.current_wave)
	hpbar.max_value = max_hp
	hpbar.value = hp
	$CanvasLayer/Control/ProgressBar/Label.text = var_to_str(hp) + "/" + var_to_str(max_hp)
	gold_text.text = "$" + var_to_str(gold)
	dmg_text.text = var_to_str(strength)
	if too_fast:
		attack_speed_text.text = "Too fast!"
	else:
		attack_speed_text.text = var_to_str(cooldown) + "s"
	crit_chance_text.text = var_to_str(crit_chance * 100) + "%"
	crit_mod_text.text = "x" + var_to_str(crit_mod)

func _on_world_new_wave() -> void:
	updateUI(true)
