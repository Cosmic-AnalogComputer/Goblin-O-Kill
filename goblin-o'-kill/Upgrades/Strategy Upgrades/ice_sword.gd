extends Node

static var global_level : int

static func apply_upgrade(attack : Punch, level : int):
	global_level = level
	attack.connect("hit",on_hit)

static func on_hit(enemy : Goblin, attack : Punch):
	if randf() <= 0.2 * global_level:
		attack.attack_particles.append(load("uid://bh83opm1cjxys"))
		attack.modulate = Color.SKY_BLUE
		enemy.receive_damage(attack.damage * 0.4 * global_level)
