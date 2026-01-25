extends Node

static func apply_upgrade(attack : Punch) -> void:
	if attack.crit:
		attack.connect("hit", on_hit)

static func on_hit(enemy : Goblin, attack : Punch) -> void:
	if randf() <= 1.0:
		attack.damage *= 3
		attack.modulate = Color.GOLD
		attack.scale = Vector2(1.1,1.1)
		attack.attack_particles = load("uid://ceiq1o0gfi7jx")
