class_name Goblin
extends CharacterBody2D

@export_group("Stats")
@export var hp = 10
@export var speed = 200
@export var gold = 1
@export_subgroup("Combat")
@export var damage = 1
@export var delay : float = 1.0 ## Time between the start of an attack and the hit
@export var cooldown : float = 1.0 ## Time between the end of an attack and the beggining of the next
@export var meleeAttack : bool = true
@export var range : float = 90
@export var goodAim : bool = false
@export var attackIsChild = true
@export var attackScene : PackedScene = preload("res://Scenes/Attacks/punch.tscn")

var player : Player
@export_group("Animations")
@export var hasSimetricAnimation = true
@export var idle : Array[String] = ["idle","top_idle"]
@export var walk : Array[String] = ["walk"] ## Minimun of 4
@export var attack_anim : Array[String] = ["attack1"]

@onready var startingSpeed = speed
@onready var anim = $AnimatedSprite2D

@export_group("AI")
@export var initial_state : State
var current_state : State
var states : Dictionary = {}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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

func receive_damage(damage):
	hp -= damage
	if hp <= 0:
		queue_free()
