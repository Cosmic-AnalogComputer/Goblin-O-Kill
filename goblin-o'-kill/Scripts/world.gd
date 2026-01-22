extends Node2D

signal new_wave()

@export_group("Dev Tools")
@export var devMode : bool = false ## Enables developer tools
@export_multiline var devControls : String
@export var showShop : bool = false ## Shows shop at the start of the scene
@export_subgroup("Starter Wave")
@export var hasStarterWave = false ## If true, will begin the game at a wave equal to starterWave
@export var starterWave : int ## Starts the game at this wave, if has starter wave is enabled

var itemScene = preload("res://Scenes/Items/upgrade_item.tscn")

@export_group("Wave System")
@export var goblins : Array[PackedScene] = [preload("res://Scenes/Main/Enemies/goblin.tscn"),\
preload("res://Scenes/Main/Enemies/thrower.tscn")]
@export var goblin_prices : Array[int] = [1, 3] ## Asign prices in the order of the goblins list
#var prices : Array[int] = [20,15,7,4,3,1] # 1-Goblin 2-Thrower 3-Buffed Goblin 4-Guard 5-Wizard 6-Boss
@export var events : Array[waveEvent] ## Priority is established from top to bottom (so the lower, the higher priority)

@export_group("Shop")
@export var Upgrades : Array[Upgrade] = [preload("res://Scripts/Upgrades/electricsword.tres")]

var inStock : bool = true
var playing_music = true
var ivolume : float = 0.5

@onready var wave_container = $Wave
@onready var musicStream = $AudioStreamPlayer

func _ready() -> void:
	if !showShop:
		hide_shop(false)
	if hasStarterWave:
		GlobalVariables.current_wave = starterWave - 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
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
	playing_music = true
	var amounts : Array[int]
	for event in events:
		if event.appearOnce and GlobalVariables.current_wave == event.wave:
			amounts = event.goblins
		elif GlobalVariables.current_wave % event.wave == 0:
			amounts = event.goblins
			if event.DoubleEachInstance:
				for i in amounts.size():
					amounts[i] *= GlobalVariables.current_wave / event.wave
	if amounts.is_empty():
		amounts = buy_goblins(GlobalVariables.current_wave)
	#print(amounts)
	for g in amounts.size():
		for i in amounts[g]:
			var goblin = goblins[g].instantiate()
			goblin.position = Vector2(randi_range(50,1150),randi_range(50,1150))
			wave_container.add_child(goblin)
	inStock = false
	#print(amounts)
	#print("goblinos: ", var_to_str(wave_container.get_child_count()), " oleada: ", \
	#var_to_str(GlobalVariables.current_wave))

func buy_goblins(num) -> Array[int]:
	var amounts : Array[int]
	for g in goblins.size():
		amounts.append(0)
	while num > 0:
		var ran_goblin = randi_range(0,goblins.size() - 1)
		if num - goblin_prices[ran_goblin] >= 0:
			num -= goblin_prices[ran_goblin]
			amounts[ran_goblin] += 1
	#print("bought goblins: ", amounts)
	return amounts

func restock():
	if GlobalVariables.record < GlobalVariables.current_wave:
		GlobalVariables.record = GlobalVariables.current_wave
	playing_music = false
	for loop in get_tree().get_node_count_in_group("On Victory"):
		get_tree().get_nodes_in_group("On Victory")[loop].show()
	for upgrades in get_tree().get_node_count_in_group("Upgrades"):
		get_tree().get_nodes_in_group("Upgrades")[upgrades].\
			load_item(Upgrades.pick_random())
	$"Wave Button/Interaction Component".monitoring = true
	$"Wave Button".set_collision_layer_value(1,true)
	$Shop.set_collision_layer_value(1,true)
	$"Shop/Interaction Component".monitoring = true

func _on_interaction_component_interacted(user: Player) -> void:
	GlobalVariables.current_wave += 1
	make_new_wave()
	$Tutorials.hide()

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



# Dev tools

func _unhandled_input(event: InputEvent) -> void:
	if devMode:
		if Input.is_action_just_pressed("k"):
			for k in wave_container.get_child_count():
				wave_container.get_child(k).receive_damage(100)
		if Input.is_action_just_pressed("g"):
			$Player.gold += 100
			$Player.updateUI()
		if Input.is_action_just_pressed("y"):
			if $Player.inmortal:
				$Player.inmortal = false
			else:
				$Player.inmortal = true
		if Input.is_action_just_pressed("p"):
			if $Player/CollisionShape2D.disabled:
				$Player/CollisionShape2D.disabled = false
			else:
				$Player/CollisionShape2D.disabled = true

func _on_restocker_interaction_interacted(user: Player) -> void:
	if user.gold >= 15:
		user.gold -= 15
		user.updateUI()
		restock()
