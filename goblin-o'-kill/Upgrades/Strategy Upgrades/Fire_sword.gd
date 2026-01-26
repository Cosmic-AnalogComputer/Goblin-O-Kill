extends Node

static func apply_upgrade(attack : Punch, level : int) -> void:
	attack.modulate = Color.ORANGE_RED
	var particle = load("uid://yeuglifsqavu")
	if not particle in attack.attack_particles:
		attack.attack_particles.append(particle)
