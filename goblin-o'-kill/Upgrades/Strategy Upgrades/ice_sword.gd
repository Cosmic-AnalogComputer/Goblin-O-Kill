extends Node

static var global_level : int

static func apply_upgrade(attack : Punch, level : int):
	global_level = level
	attack.connect("hit",on_hit)

static func on_hit(enemy : Goblin, attack : Punch):
	if randf() <= 0.2:
		attack.attack_particles.append(load("uid://bh83opm1cjxys"))
		attack.anim.self_modulate = Color.SKY_BLUE
		var ice_time : float
		for lvl in global_level:
			ice_time += 0.4 * (1 / (lvl))
		enemy.debuff("ice",{"speed" : 50},ice_time, Color.LIGHT_SKY_BLUE)
		var ice_dmg : float
		for lvl in global_level:
			ice_dmg += 0.4 * (1 / (lvl + 1))
		enemy.receive_damage(attack.damage * ice_dmg)
