extends Node

static var global_level : int

static func apply_upgrade(attack : Punch, level : int):
	global_level = level
	attack.connect("hit",on_hit)

static func on_hit(enemy : Goblin, attack : Punch):
	if randf() <= 0.2:
		attack.attack_particles.append(load("uid://bh83opm1cjxys"))
		attack.anim.self_modulate = Color.SKY_BLUE
		enemy.debuff("ice",{"speed" : 50},1.0, Color.BLUE)
		enemy.receive_damage(attack.damage * 0.4 * global_level)
