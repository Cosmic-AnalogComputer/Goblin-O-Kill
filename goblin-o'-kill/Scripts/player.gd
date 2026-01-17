class_name Player
extends CharacterBody2D

enum STATES {IDLE,ROLLING,DEAD}
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
@export var attackScene = preload("res://Scenes/Attacks/punch.tscn")

var rollDirection : Vector2
var idle = "idle"
var walk = "walk"
var roll = "roll"
var canAttack := true
var currentAttack = 1
var speed = 350


@onready var startingSpeed = speed
@onready var hitbox = $CollisionShape2D
@onready var anim = $AnimatedSprite2D
@onready var hpbar = $CanvasLayer/Control/ProgressBar
@onready var key_tip = $AnimatedSprite2D/Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hpbar.max_value = max_hp


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$CanvasLayer/Control/RichTextLabel.text = "damage " + var_to_str(strength)
	var direction = Input.get_vector("a","d","w","s")
	if direction and state == STATES.IDLE:
		velocity = direction.normalized() * speed
		anim.play(walk)
		rollDirection = direction
		
		if direction.x < 0:
			anim.flip_h = true
		else:
			anim.flip_h = false
		if direction.y < 0:
			walk = "top_walk"
			idle = "top_idle"
		else:
			walk = "walk"
			idle = "idle"
	elif state == STATES.IDLE:
		velocity = Vector2.ZERO
		rollDirection = Vector2.ZERO
		anim.play(idle)
	
	if Input.is_action_pressed("shift") and state == STATES.IDLE:
		if rollDirection:
			state = STATES.ROLLING
			canAttack = false
			velocity = rollDirection.normalized() * 300
			set_collision_layer_value(2,false)
			anim.play("roll")
			$RollAudio.play()
			$IFrames.start()
	
	move_and_slide()
	
	# ATTACK
	if Input.is_action_pressed("C1") and canAttack:
		attack()
		speed = 250
	

func _on_i_frames_timeout() -> void:
	set_collision_layer_value(2,true)
	state = STATES.IDLE
	canAttack = true

func receive_damage(dmg):
	hp -= dmg
	if hp <= 0:
		state = STATES.DEAD
		queue_free()
	hpbar.value = hp

func attack():
	canAttack = false
	$CD.start(cooldown)
	var attack = attackScene.instantiate()
	attack.position = get_local_mouse_position().normalized() * 75
	attack.look_at(get_local_mouse_position() * 75)
	attack.set_collision_mask(4)
	var hurt = get_dmg()
	attack.damage = hurt.x
	if hurt.y == 1.0:
		attack.modulate = Color.DEEP_SKY_BLUE
	add_child(attack)


func _on_cd_timeout() -> void:
	canAttack = true
	speed = startingSpeed

func get_dmg() -> Vector2:
	var dmg : int
	var crit : bool
	dmg = strength
	if randf() <= crit_chance:
		dmg * crit_mod
		crit = true
	
	return Vector2(dmg,float(crit))

func updateUI():
	$CanvasLayer/Control/PanelContainer/RichTextLabel.text = "Wave " + var_to_str(get_parent().wave)

func _on_world_new_wave() -> void:
	updateUI()
