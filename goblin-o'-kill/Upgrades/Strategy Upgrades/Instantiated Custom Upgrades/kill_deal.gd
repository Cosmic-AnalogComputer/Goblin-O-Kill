extends InstantiatedUpgrade

var upgrade_count := 50

func _ready() -> void:
	player.connect("on_attack", on_attack)

func on_attack(attack : Punch) -> void:
	attack.connect("kill", on_kill)

func on_kill(enemy : Goblin, attack : Punch) -> void:
	player.gold_gain += 0.01 * level
	upgrade_count -= 1
	if upgrade_count <= 0:
		upgrade_count = 50
		level -= 1
	if level <= 0:
		player.instantiated_upgrades.erase(name)
		queue_free()
