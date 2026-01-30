extends InstantiatedUpgrade

var upgrade_count := 50:
	set(value):
		upgrade_count = value
		if upgrade_count <= 0:
			queue_free()

func on_attack(attack : Punch) -> void:
	attack.connect("kill", on_kill)

func on_kill(enemy : Goblin, attack : Punch) -> void:
	if level > 1:
		upgrade_count += 50 * (level - 1)
	player.gold_gain += 0.01
	upgrade_count -= 1
