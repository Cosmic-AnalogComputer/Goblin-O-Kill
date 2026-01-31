extends Node

@export var chances : Dictionary[int, float] ## Ordered from highest to lowest

func buff(enemy : Goblin) -> void:
	print("buffed")
	var mod = GlobalVariables.buffed_enemies_mod
	enemy.hp *= mod
	enemy.damage *= 1.5 * mod
	enemy.gold *= 1.2 * mod
	enemy.scale += Vector2(0.05,0.05)

func get_buff_chance() -> float:
	var buff_chance := 0.0
	var wave := GlobalVariables.current_wave
	
	for c in chances.keys():
		if wave >= c:
			buff_chance = chances[c]
		else:
			break
	
	buff_chance *= GlobalVariables.difficulty
	return buff_chance
