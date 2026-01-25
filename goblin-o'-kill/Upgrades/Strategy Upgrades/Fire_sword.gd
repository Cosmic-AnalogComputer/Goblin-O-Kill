extends Node

static func apply_upgrade(attack : Punch):
	attack.modulate = Color.ORANGE_RED
	attack.attack_particles = load("uid://yeuglifsqavu")
