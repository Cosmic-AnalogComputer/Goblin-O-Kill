extends Node

static func apply_upgrade(attack : Punch) -> void:
	if attack.crit and randf() <= 0.02:
		print("bonk")
		attack.damage *= 3
		attack.modulate = Color.GOLD
		attack.scale = Vector2(1.1,1.1)
		attack.attack_particles = load("uid://ceiq1o0gfi7jx")
