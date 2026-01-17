extends Node

signal new_wave()

var upgrades : Array[Upgrade] = [load("res://Scripts/Upgrades/dumbell.tres"), load("res://Scripts/Upgrades/adrenaline.tres")]
var itemScene = preload("res://Scenes/Upgrades/upgrade_item.tscn")

var goblinScene = preload("res://Scenes/Main/goblin.tscn")
var prices : Dictionary = {1:1, 2:3, 3:5, 4:10, 5:20} # 1-Goblin 2-Thrower 3-Guard 4-Wizard 5-Boss
var playing_music = true
var ivolume : float = 0.5

@onready var wave_container = $Wave
@onready var musicStream = $AudioStreamPlayer
@onready var timedCheck = $checker

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	make_new_wave(GlobalVariables.wave)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	musicStream.volume_db = lerp(GlobalVariables.music_volume,GlobalVariables.music_volume -10.0, ivolume)
	if !playing_music and ivolume < 1.0:
		ivolume += delta
	elif ivolume > 0.0:
		ivolume -= delta

func make_new_wave(num):
	emit_signal("new_wave")
	GlobalVariables.wave_dmg_mod += 0.1
	playing_music = true
	var amounts = buy_goblins(GlobalVariables.wave, {1:0,2:0,3:0,4:0,5:0})
	
	for b in amounts[2]:
		var Bgoblin = goblinScene.instantiate()
		Bgoblin.position = Vector2(randi_range(-50,100),randi_range(-50,100))
		Bgoblin.buffed = true
		Bgoblin.scale = Vector2(1.2,1.2)
		Bgoblin.modulate = Color.MEDIUM_PURPLE
		Bgoblin.connect("death",timedCheck.start)
		wave_container.add_child(Bgoblin)
	for g in amounts[1]:
		var goblin = goblinScene.instantiate()
		goblin.position = Vector2(randi_range(-50,100),randi_range(-50,100))
		goblin.connect("death",timedCheck.start)
		wave_container.add_child(goblin)
	
	#print("goblinos: ", var_to_str(wave_container.get_child_count()), " oleada: ", \
	#var_to_str(GlobalVariables.wave))

func check_goblin_count():
	if wave_container.get_child_count() <= 0:
		GlobalVariables.wave += 1
		playing_music = false
		var itemPos = Vector2(30,30)
		for i in 3:
			spawn_item(itemPos)
			itemPos.x += 30
		await get_tree().create_timer(7.5).timeout
		make_new_wave(GlobalVariables.wave)

func buy_goblins(num, amounts) -> Dictionary:
	while num >= prices[2]:
		num -= prices[2]
		amounts[2] += 1
	while num >= prices[1]:
		num -= prices[1]
		amounts[1] += 1
	#print(amounts, " num: ", num)
	return amounts

func spawn_item(pos : Vector2):
	var item = itemScene.instantiate()
	item.UPGRADE = upgrades[randi_range(0,1)]
	item.position = pos
	add_child(item)

func _on_checker_timeout() -> void:
	check_goblin_count()
