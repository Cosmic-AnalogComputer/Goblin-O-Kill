extends CharacterBody2D

@export_group("Stats")
@export var hp = 3
@export var speed = 200
@export_group("Combat")
@export var delay : float = 1.0
@export var cooldown : float = 1.0
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

@onready var anim = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	target = get_tree().get_first_node_in_group("Player")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if target:
		direction = target.global_position - position
		if direction.length() > chaseRange:
			velocity = direction.normalized() * speed
		else:
			velocity = Vector2.ZERO
			
			# Attack
			if canAttack:
				attack()
	
	if velocity.length() > 0:
		anim.play(walk)
	else:
		anim.play(idle)
	
	if velocity.y < 0:
		walk = "top_walk"
		idle = "top_idle"
	elif velocity.y > 0:
		walk = "walk"
		idle = "idle"
	
	if velocity.x < 0:
		anim.flip_h = true
	else:
		anim.flip_h = false
	
	move_and_slide()

func attack():
	canAttack = false
	modulate = Color.RED
	$Delay.start(delay)

func receive_damage(dmg):
	hp -= dmg
	if hp <= 0:
		queue_free()

func _on_cd_timeout() -> void:
	canAttack = true

func _on_delay_timeout() -> void:
	modulate = Color.WHITE
	$CD.start(cooldown)
	var attack = attackScene.instantiate()
	if attackAtLocation:
		attack.position = projectilePos
	else:
		attack.position = direction.normalized() * chaseRange
	attack.set_collision_mask(2)
	if attackIsChild:
		add_child(attack)
	else:
		get_tree().add_child(attack)
