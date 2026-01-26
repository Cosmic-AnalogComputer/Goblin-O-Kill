extends Node

static var global_level : int

static func apply_upgrade(attack : Punch, level : int) -> void:
	global_level = level
	attack.connect("hit", on_hit)

static func on_hit(enemy : Goblin, attack : Punch) -> void:
	if randf() <= 0.02 * global_level:
		attack.damage *= 3
		attack.modulate = Color.GOLD
		attack.scale = Vector2(1.1,1.1)
		var particle = load("uid://ceiq1o0gfi7jx")
		if not particle in attack.attack_particles:
			attack.attack_particles.append(particle)
