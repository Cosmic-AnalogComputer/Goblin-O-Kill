extends Node

static func apply_upgrade(attack : Punch, level : int) -> void:
	attack.anim.self_modulate = Color(randf(),randf(),randf())
	var particle = load("uid://cogyjnnh18pct")
	if not particle in attack.attack_particles:
		attack.attack_particles.append(particle)
