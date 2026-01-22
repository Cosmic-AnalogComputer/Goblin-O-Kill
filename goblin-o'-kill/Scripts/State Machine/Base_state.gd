class_name State
extends Node
# Huge thanks to Bitlytic on YT for making a tutorial on this!!

signal transitioned()

@onready var enemy : Goblin = get_parent()
@onready var target : Player = get_tree().get_first_node_in_group("Player")

func enter():
	pass

func exit():
	pass

func update(delta : float):
	pass

func physics_update(delta : float):
	pass
