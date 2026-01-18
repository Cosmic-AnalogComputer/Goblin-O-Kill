extends Node2D

signal new_wave()

@export var canKillAll : bool = false ## Dev tool. Kills all goblins
var itemScene = preload("res://Scenes/Items/upgrade_item.tscn")

var goblinScene : Array[PackedScene] = [preload("res://Scenes/Main/buff_goblin.tscn"),\
preload("res://Scenes/Main/thrower.tscn"),preload("res://Scenes/Main/goblin.tscn"),\
preload("res://Scenes/Main/goblin.tscn"),preload("res://Scenes/Main/buff_goblin.tscn"),\
preload("res://Scenes/Main/goblin.tscn")]
#var prices : Array[int] = [20,15,7,4,3,1] # 1-Goblin 2-Thrower 3-Buffed Goblin 4-Guard 5-Wizard 6-Boss
var prices : Array[int] = [4,3,1] # 1-Goblin 2-Thrower 3-Buffed Goblin 4-Guard 5-Wizard 6-Boss
var playing_music = true
var ivolume : float = 0.5

@onready var wave_container = $Wave
@onready var musicStream = $AudioStreamPlayer
@onready var timedCheck = $checker

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	make_new_wave()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("k") and canKillAll:
		for k in wave_container.get_child_count():
			wave_container.get_child(k).receive_damage(100)
	
	musicStream.volume_db = lerp(GlobalVariables.music_volume * -10.0,GlobalVariables.music_volume * -15.0, ivolume)
	if !playing_music and ivolume < 1.0:
		ivolume += delta
	elif ivolume > 0.0:
		ivolume -= delta

func make_new_wave():
	for loop in get_tree().get_node_count_in_group("On Victory"):
		get_tree().get_nodes_in_group("On Victory")[loop].hide()
	$"Wave Button/Interaction Component".monitoring = false
	$"Wave Button/CollisionShape2D".disabled = true
	$"Wave Button/CollisionShape2D2".disabled = true
	$"Wave Button/CollisionShape2D3".disabled = true
	$"Wave Button/CollisionShape2D4".disabled = true
	$Shop.set_collision_layer_value(1,false)
	$"Shop/Interaction Component".monitoring = false
	emit_signal("new_wave")
	GlobalVariables.wave_dmg_mod = 1 + (GlobalVariables.current_wave * 0.1)
	print(GlobalVariables.wave_dmg_mod)
	playing_music = true
	var amounts = buy_goblins(GlobalVariables.current_wave, [0,0,0,0,0,0])
	for g in amounts.size():
		for i in amounts[g]:
			var goblin = goblinScene[g].instantiate()
			goblin.position = Vector2(randi_range(50,1150),randi_range(50,1150))
			goblin.goldValue = _get_gold(goblinScene[g], g)
			if GlobalVariables.difficulty >= 2:
				goblin.hp = round(goblin.hp * GlobalVariables.wave_dmg_mod)
			goblin.connect("death",timedCheck.start)
			wave_container.add_child(goblin)
	
	#print("goblinos: ", var_to_str(wave_container.get_child_count()), " oleada: ", \
	#var_to_str(GlobalVariables.wave))

func check_goblin_count():
	if wave_container.get_child_count() <= 0:
		if GlobalVariables.record < GlobalVariables.current_wave:
			GlobalVariables.record = GlobalVariables.current_wave
		GlobalVariables.current_wave += 1
		playing_music = false
		restock()

func buy_goblins(num, amounts) -> Array:
	for i in prices.size():
		while num >= prices[i]:
			num -= prices[i]
			amounts[i] += 1
	print(amounts, " num: ", num)
	return amounts

func restock():
	for loop in get_tree().get_node_count_in_group("On Victory"):
		get_tree().get_nodes_in_group("On Victory")[loop].show()
	$"Wave Button/Interaction Component".monitoring = true
	$"Wave Button/CollisionShape2D".disabled = false
	$"Wave Button/CollisionShape2D2".disabled = false
	$"Wave Button/CollisionShape2D3".disabled = false
	$"Wave Button/CollisionShape2D4".disabled = false
	$Shop.set_collision_layer_value(1,true)
	$"Shop/Interaction Component".monitoring = true
	for i in 3:
		var item = itemScene.instantiate()
		item.UPGRADE = load(GlobalVariables.upgrades.pick_random())
		item.position = get_tree().get_nodes_in_group("On Victory")[i].position
		connect("new_wave", item.queue_free)
		add_child(item)

func _on_checker_timeout() -> void:
	check_goblin_count()

func _on_interaction_component_interacted(user: Player) -> void:
	make_new_wave()

func _get_gold(goblino, i) -> int:
	var gold : int
	gold = prices[i] + (GlobalVariables.current_wave * 0.5)
	return gold
