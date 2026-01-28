extends InstantiatedUpgrade

func _ready() -> void:
	if player:
		player.connect("damaged", on_damage)

func on_damage(dmg : int) -> void:
	if randf() <= 0.15 * level:
		player.gold += dmg
