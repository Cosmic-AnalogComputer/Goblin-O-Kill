extends StaticBody2D

@export var UPGRADE : Upgrade = preload("res://Scripts/Upgrades/dumbell.tres")
var usage = 0

func load_item(new_upgrade : Upgrade):
	$"Interaction Component".monitoring = true
	UPGRADE = new_upgrade
	usage = 0
	$Sprite2D.show()
	$Sprite2D.texture = UPGRADE.texture
	$PanelContainer/MarginContainer/VBoxContainer/Name.text = UPGRADE.name
	$PanelContainer/MarginContainer/VBoxContainer/Description.text = UPGRADE.description
	$PanelContainer/MarginContainer/VBoxContainer/Price.text = "Price: $" + var_to_str(UPGRADE.price)

func _upgrade(player):
	usage += 1
	if usage == 1:
		player.max_hp += UPGRADE.max_health
		if player.hp <= (player.max_hp - UPGRADE.health):
			player.receive_damage(-UPGRADE.health)
		else:
			player.receive_damage(-(player.max_hp - player.hp))
		player.strength += UPGRADE.damage
		if player.crit_chance + UPGRADE.crit_chance <= 1.0:
			player.crit_chance += UPGRADE.crit_chance
		else:
			player.crit_chance = 1.0
		player.crit_mod += UPGRADE.crit_mod
		if player.cooldown > 0.1 + UPGRADE.attack_speed:
			player.cooldown -= UPGRADE.attack_speed
		elif player.too_fast == false:
			player.too_fast = true
			player.cooldown = 0.1
		player.gold_gain += UPGRADE.gold_gain
		
		player.gold -= UPGRADE.price
		
		player.updateUI()
		
		#Disabling
		$Sprite2D.hide()
		$"Interaction Component".monitoring = false
		$PanelContainer.hide()

func _on_interaction_component_interacted(user: Player) -> void:
	if user.gold >= UPGRADE.price:
		_upgrade(user)

func _on_interaction_component_body_entered(body: Node2D) -> void:
	$PanelContainer.show()

func _on_interaction_component_body_exited(body: Node2D) -> void:
	$PanelContainer.hide()

func _on_visibility_changed() -> void:
	set_collision_layer_value(1,visible)
