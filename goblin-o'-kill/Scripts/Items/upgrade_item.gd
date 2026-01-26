extends StaticBody2D

@export var UPGRADE : Upgrade
@export var item_particles : GPUParticles2D
var usage = 0

@onready var spawn_particles = $"Spawn Particles"
@onready var sprite = $Sprite2D

func load_item(new_upgrade : Upgrade):
	$"Interaction Component".monitoring = true
	UPGRADE = new_upgrade
	usage = 0
	spawn_particles.restart()
	spawn_particles.emitting = true
	sprite.show()
	if UPGRADE.texture:
		sprite.texture = UPGRADE.texture
	$PanelContainer/MarginContainer/VBoxContainer/Name.text = UPGRADE.name
	$PanelContainer/MarginContainer/VBoxContainer/Description.text = UPGRADE.description
	$PanelContainer/MarginContainer/VBoxContainer/Price.text = "Price: $" + var_to_str(UPGRADE.price)
	if UPGRADE.item_particles:
		item_particles.restart()
		item_particles.process_material = UPGRADE.item_particles
		item_particles.emitting = true
	else:
		item_particles.restart()
		item_particles.emitting = false
		item_particles.process_material = null

func _upgrade(player : Player):
	usage += 1
	if usage == 1:
		player.max_hp += UPGRADE.max_health
		if UPGRADE.health:
			player.receive_damage(-(UPGRADE.health))
		player.strength += UPGRADE.damage
		player.crit_chance += UPGRADE.crit_chance
		player.crit_mod += UPGRADE.crit_mod
		player.cooldown -= UPGRADE.attack_speed
		
		player.gold_gain += UPGRADE.gold_gain
		
		# Percentajes
		player.max_hp += player.max_hp * UPGRADE.p_max_health
		if UPGRADE.p_health:
			player.receive_damage(-(player.max_hp * UPGRADE.p_health))
		player.strength += player.strength * UPGRADE.p_damage
		player.crit_mod += player.crit_mod * UPGRADE.p_crit_mod
		player.cooldown -= player.cooldown * UPGRADE.p_attack_speed
		
		# Custom
		if UPGRADE.instantiate_custom_upgrade:
			var upgrade_node = Node.new()
			upgrade_node.set_script(UPGRADE.custom_upgrade)
			player.add_child(upgrade_node)
		elif UPGRADE.custom_upgrade:
			if player.strategy_upgrades.has(UPGRADE.custom_upgrade):
				player.strategy_upgrades[UPGRADE.custom_upgrade] += 1
			else:
				player.strategy_upgrades.set(UPGRADE.custom_upgrade, 1)
		
		#Closing
		player.gold -= UPGRADE.price
		
		#Disabling
		sprite.hide()
		$"Interaction Component".monitoring = false
		$PanelContainer.hide()

func _on_interaction_component_interacted(user: Player) -> void:
	if user.gold >= UPGRADE.price:
		_upgrade(user)
		item_particles.restart()
		item_particles.emitting = false

func _on_interaction_component_body_entered(_body: Node2D) -> void:
	$PanelContainer.show()

func _on_interaction_component_body_exited(_body: Node2D) -> void:
	$PanelContainer.hide()

func _on_visibility_changed() -> void:
	set_collision_layer_value(1,visible)
	$"Interaction Component".monitoring = visible
