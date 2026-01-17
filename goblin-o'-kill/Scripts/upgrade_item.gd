extends Area2D

@export var UPGRADE : Upgrade = preload("res://Scripts/Upgrades/dumbell.tres")
var usage = 0

func _ready() -> void:
	$Sprite2D.texture = UPGRADE.texture
	$Label.text = UPGRADE.name

func _on_body_entered(body: Node2D) -> void:
	usage += 1
	if body is Player and usage == 1:
		print("picked up: ", UPGRADE.name)
		var player = body # easier writing lol
		player.speed += UPGRADE.speed
		player.max_hp += UPGRADE.max_health
		if player.hp < player.max_hp:
			player.receive_damage(-UPGRADE.health)
		else:
			player.receive_damage(-(player.max_hp - player.hp))
		player.strength += UPGRADE.damage
		if player.crit_chance < 1.0:
			player.crit_chance += UPGRADE.crit_chance
		player.crit_mod += UPGRADE.crit_mod
		if player.cooldown > 0.0:
			player.cooldown -= UPGRADE.attack_speed
		
		player.hpbar.max_value = player.max_hp
		
		queue_free()
