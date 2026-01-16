extends CharacterBody2D

enum STATES {IDLE,ROLLING,DEAD}
var state : STATES = STATES.IDLE

@export var speed = 350
@export var max_hp = 15
@export var hp = 15
@export var attackScene = preload("res://Scenes/Attacks/punch.tscn")
@export var attackIsChild := true

var rollDirection : Vector2
var idle = "idle"
var walk = "walk"
var roll = "roll"
var goblinScene = preload("res://Scenes/goblin.tscn")
var canAttack := true

@onready var startingSpeed = speed
@onready var hitbox = $CollisionShape2D
@onready var anim = $AnimatedSprite2D
@onready var hpbar = $CanvasLayer/Control/ProgressBar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hpbar.max_value = max_hp


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
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
			velocity = rollDirection.normalized() * 300
			hitbox.disabled = true
			anim.play("roll")
			$IFrames.start()
	
	move_and_slide()
	
	# ATTACK
	if Input.is_action_pressed("C1") and canAttack:
		attack()
	
	
	
	if Input.is_action_just_pressed("ui_accept"):
		var goblin = goblinScene.instantiate()
		goblin.position = Vector2(0,0)
		get_parent().add_child(goblin)

func _on_i_frames_timeout() -> void:
	hitbox.disabled = false
	state = STATES.IDLE

func receive_damage(dmg):
	hp -= dmg
	if hp <= 0:
		queue_free()
	hpbar.value = hp

func attack():
	canAttack = false
	$CD.start()
	var attack = attackScene.instantiate()
	attack.position = get_local_mouse_position().normalized() * 75
	attack.set_collision_mask(4)
	if attackIsChild:
		add_child(attack)
	else:
		get_tree().add_child(attack)

func _on_cd_timeout() -> void:
	canAttack = true
