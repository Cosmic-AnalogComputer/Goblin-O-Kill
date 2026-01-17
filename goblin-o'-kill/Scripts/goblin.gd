extends CharacterBody2D

signal death()

@export_group("Stats")
@export var hp = 3
@export var speed = 200
var goldValue : int
@export_group("Combat")
@export var strength = 1
@export var delay : float = 1.0
@export var cooldown : float = 1.0
@export var buffed := false
@export var chaseRange : float = 75
@export var attackAtLocation := false
@export var attackScene = preload("res://Scenes/Attacks/punch.tscn")
@export var attackIsChild := true

var target : CharacterBody2D
var direction : Vector2
var projectilePos : Vector2
var canAttack := true
var idle = "idle"
var walk = "walk"
var attack_anim = "attack"

@onready var startingSpeed = speed
@onready var anim = $AnimatedSprite2D
@onready var startingColor = modulate

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	target = get_tree().get_first_node_in_group("Player")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if target:
		direction = target.global_position - position
		if direction.length() > chaseRange:
			velocity = direction.normalized() * speed
			if canAttack:
				anim.play(walk)
		else:
			velocity = Vector2.ZERO
			# Attack
			if canAttack:
				attack()
	
	if velocity.y < 0:
		walk = "top_walk"
		idle = "top_idle"
		attack_anim = "top_attack"
	if velocity.y > 0:
		walk = "walk"
		idle = "idle"
		attack_anim = "attack"
	
	if velocity.x < 0:
		anim.flip_h = true
	if velocity.x > 0:
		anim.flip_h = false
	
	move_and_slide()

func attack():
	speed = 0
	canAttack = false
	anim.play(attack_anim)
	$Delay.start(delay)

func receive_damage(dmg):
	hp -= dmg
	if hp <= 0:
		emit_signal("death")
		target.gold += goldValue
		target.updateUI()
		queue_free()

func _on_cd_timeout() -> void:
	canAttack = true
	speed = startingSpeed

func _on_delay_timeout() -> void:
	modulate = startingColor
	$CD.start(cooldown)
	var attack = attackScene.instantiate()
	if attackAtLocation:
		attack.position = projectilePos
	else:
		attack.position = direction.normalized() * 30
	attack.look_at(direction * 60)
	attack.set_collision_mask(2)
	attack.damage = get_damage()
	attack.play = "null"
	if attackIsChild:
		add_child(attack)
	else:
		get_tree().add_child(attack)

func get_damage() -> int:
	var dmg : int
	dmg = round(strength * GlobalVariables.wave_dmg_mod)
	return dmg
