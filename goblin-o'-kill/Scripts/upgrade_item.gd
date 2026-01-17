extends Node2D

@export var UPGRADE : Upgrade = preload("res://Scripts/Upgrades/dumbell.tres")
var usage = 0

func _ready() -> void:
	$Sprite2D.texture = UPGRADE.texture
	$Label.text = UPGRADE.name

func _upgrade(player):
	usage += 1
	if usage == 1:
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

func _on_interaction_component_interacted(user: Player) -> void:
	_upgrade(user)
