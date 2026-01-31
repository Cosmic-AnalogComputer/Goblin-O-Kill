class_name InstantiatedUpgrade
extends Node

@onready var player : Player = get_parent()
@export var level := 1

func _ready() -> void:
	pass

func on_damage(dmg : int) -> void:
	pass

func on_attack(attack : Punch) -> void:
	pass
