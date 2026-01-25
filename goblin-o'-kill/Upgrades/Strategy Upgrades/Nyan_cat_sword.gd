extends Node

static func apply_upgrade(attack : Punch) -> void:
	attack.modulate = Color(randf(),randf(),randf())
	attack.attack_particles = load("uid://cogyjnnh18pct")
