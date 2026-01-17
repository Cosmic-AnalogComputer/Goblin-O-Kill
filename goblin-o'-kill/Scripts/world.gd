extends Node

signal new_wave()

var upgrades : Array[Upgrade] = [load("res://Scripts/Upgrades/dumbell.tres"), load("res://Scripts/Upgrades/adrenaline.tres")]
var itemScene = preload("res://Scenes/Upgrades/upgrade_item.tscn")

var goblinScene : Array[PackedScene] = [preload("res://Scenes/Main/buff_goblin.tscn"),\
preload("res://Scenes/Main/goblin.tscn"),preload("res://Scenes/Main/goblin.tscn"),\
preload("res://Scenes/Main/goblin.tscn"),preload("res://Scenes/Main/buff_goblin.tscn"),\
preload("res://Scenes/Main/goblin.tscn")]
#var prices : Array[int] = [20,15,7,4,3,1] # 1-Goblin 2-Thrower 3-Buffed Goblin 4-Guard 5-Wizard 6-Boss
var prices : Array[int] = [4,3,1] # 1-Goblin 2-Thrower 3-Buffed Goblin 4-Guard 5-Wizard 6-Boss
var playing_music = true
var ivolume : float = 0.5

var wave = 1

@onready var wave_container = $Wave
@onready var musicStream = $AudioStreamPlayer
@onready var timedCheck = $checker

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	make_new_wave(wave)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("k"):
		for k in wave_container.get_child_count():
			wave_container.get_child(k).receive_damage(100)
	
	musicStream.volume_db = lerp(GlobalVariables.music_volume,GlobalVariables.music_volume -15.0, ivolume)
	if !playing_music and ivolume < 1.0:
		ivolume += delta
	elif ivolume > 0.0:
		ivolume -= delta

func make_new_wave(num):
	$Victory.hide()
	$"Victory/Wave Button/Interaction Component".monitoring = false
	emit_signal("new_wave")
	GlobalVariables.wave_dmg_mod = 1 + (wave * 0.1)
	playing_music = true
	var amounts = buy_goblins(wave, [0,0,0,0,0,0])
	for g in amounts.size():
		for i in amounts[g]:
			var goblin = goblinScene[g].instantiate()
			goblin.position = Vector2(randi_range(50,1150),randi_range(50,1150))
			goblin.connect("death",timedCheck.start)
			wave_container.add_child(goblin)
	
	#print("goblinos: ", var_to_str(wave_container.get_child_count()), " oleada: ", \
	#var_to_str(GlobalVariables.wave))

func check_goblin_count():
	if wave_container.get_child_count() <= 0:
		if GlobalVariables.record < wave:
			GlobalVariables.record = wave
		wave += 1
		playing_music = false
		restock()

func buy_goblins(num, amounts) -> Array:
	for i in prices.size():
		while num >= prices[i]:
			num -= prices[i]
			amounts[i] += 1
		
	
	#print(amounts, " num: ", num)
	return amounts

func restock():
	$Victory.show()
	$"Victory/Wave Button/Interaction Component".monitoring = true
	for i in 3:
		var item = itemScene.instantiate()
		item.UPGRADE = upgrades[randi_range(0,1)]
		item.position = $Victory.get_child(i).position
		add_child(item)

func _on_checker_timeout() -> void:
	check_goblin_count()

func _on_interaction_component_interacted(user: Player) -> void:
	make_new_wave(wave)
