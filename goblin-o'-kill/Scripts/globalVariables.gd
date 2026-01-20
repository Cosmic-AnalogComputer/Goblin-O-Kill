extends Node

#Game
var record : int
var current_wave = 0
var wave_dmg_mod : float = 1.0
var difficulty = 3
var upgrades : Array[StringName] = ["res://Scripts/Upgrades/adrenaline.tres",\
"res://Scripts/Upgrades/Bandage.tres","res://Scripts/Upgrades/bigdice.tres",\
"res://Scripts/Upgrades/biggerdice.tres","res://Scripts/Upgrades/biggestdice.tres",\
"res://Scripts/Upgrades/bluepill.tres","res://Scripts/Upgrades/dumbell.tres",\
"res://Scripts/Upgrades/goldpill.tres","res://Scripts/Upgrades/heavydumbell.tres",\
"res://Scripts/Upgrades/medkit.tres","res://Scripts/Upgrades/redpill.tres",\
"res://Scripts/Upgrades/firesword.tres","res://Scripts/Upgrades/ironsword.tres",\
"res://Scripts/Upgrades/electricsword.tres"]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
