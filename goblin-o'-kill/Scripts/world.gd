extends Node2D

signal new_wave()

@export var canKillAll : bool = false ## Dev tool. Kills all goblins
var itemScene = preload("res://Scenes/Items/upgrade_item.tscn")

var goblinScene : Array[PackedScene] = [preload("res://Scenes/Main/buff_goblin.tscn"),\
preload("res://Scenes/Main/thrower.tscn"),preload("res://Scenes/Main/goblin.tscn"),\
preload("res://Scenes/Main/goblin.tscn"),preload("res://Scenes/Main/buff_goblin.tscn"),\
preload("res://Scenes/Main/goblin.tscn")]

var inStock : bool = true
#var prices : Array[int] = [20,15,7,4,3,1] # 1-Goblin 2-Thrower 3-Buffed Goblin 4-Guard 5-Wizard 6-Boss
var prices : Array[int] = [4,3,1] # 1-Goblin 2-Thrower 3-Buffed Goblin 4-Guard 5-Wizard 6-Boss
var playing_music = true
var ivolume : float = 0.5

@onready var wave_container = $Wave
@onready var musicStream = $AudioStreamPlayer

func _ready() -> void:
	GlobalVariables.current_wave = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("k") and canKillAll:
		for k in wave_container.get_child_count():
			wave_container.get_child(k).receive_damage(100)
	if wave_container.get_child_count() <= 0 and !inStock:
		inStock = true
		restock()
	
	musicStream.volume_db = lerp(-10.0,-15.0, ivolume)
	if !playing_music and ivolume < 1.0:
		ivolume += delta
	elif ivolume > 0.0:
		ivolume -= delta

func make_new_wave():
	hide_shop()
	emit_signal("new_wave")
	GlobalVariables.wave_dmg_mod = 1 + (GlobalVariables.current_wave * 0.1)
	#print(GlobalVariables.wave_dmg_mod)
	playing_music = true
	var amounts = buy_goblins(GlobalVariables.current_wave, [0,0,0,0,0,0])
	for g in amounts.size():
		for i in amounts[g]:
			var goblin = goblinScene[g].instantiate()
			goblin.position = Vector2(randi_range(50,1150),randi_range(50,1150))
			goblin.goldValue = _get_gold(goblinScene[g], g)
			if GlobalVariables.difficulty == 3:
				goblin.hp = round(goblin.hp * (GlobalVariables.current_wave * 0.5))
			elif GlobalVariables.difficulty == 2:
				goblin.hp = round(goblin.hp * GlobalVariables.wave_dmg_mod)
			wave_container.add_child(goblin)
	inStock = false
	
	#print("goblinos: ", var_to_str(wave_container.get_child_count()), " oleada: ", \
	#var_to_str(GlobalVariables.wave))

func buy_goblins(num, amounts) -> Array:
	for i in prices.size():
		while num >= prices[i]:
			num -= prices[i]
			amounts[i] += 1
	#print(amounts, " num: ", num)
	return amounts

func restock():
	if GlobalVariables.record < GlobalVariables.current_wave:
		GlobalVariables.record = GlobalVariables.current_wave
	playing_music = false
	for loop in get_tree().get_node_count_in_group("On Victory"):
		get_tree().get_nodes_in_group("On Victory")[loop].show()
	$"Wave Button/Interaction Component".monitoring = true
	$"Wave Button".set_collision_layer_value(1,true)
	$Shop.set_collision_layer_value(1,true)
	$"Shop/Interaction Component".monitoring = true
	for i in 3:
		var item = itemScene.instantiate()
		item.UPGRADE = load(GlobalVariables.upgrades.pick_random())
		item.position = get_tree().get_nodes_in_group("On Victory")[i].position
		connect("new_wave", item.queue_free)
		add_child(item)

func _on_interaction_component_interacted(user: Player) -> void:
	GlobalVariables.current_wave += 1
	make_new_wave()
	$Tutorials.hide()

func _get_gold(goblino, i) -> int:
	var gold : int
	gold = prices[i] + (GlobalVariables.current_wave * 0.5)
	return gold

func hide_shop(hide_altar = true):
	for loop in get_tree().get_node_count_in_group("On Victory"):
		get_tree().get_nodes_in_group("On Victory")[loop].hide()
	$"Wave Button/Interaction Component".monitoring = false
	$Shop.set_collision_layer_value(1,false)
	$"Shop/Interaction Component".monitoring = false
	if hide_altar:
		$"Wave Button/Interaction Component".monitoring = false
		$"Wave Button".set_collision_layer_value(1,false)
	else:
		$"Wave Button".show()
		$"Wave Button/Interaction Component".monitoring = true
		$"Wave Button".set_collision_layer_value(1,true)
