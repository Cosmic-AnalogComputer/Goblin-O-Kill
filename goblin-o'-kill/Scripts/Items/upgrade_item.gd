extends StaticBody2D

@export var UPGRADE : Upgrade
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
	sprite.texture = UPGRADE.texture
	$PanelContainer/MarginContainer/VBoxContainer/Name.text = UPGRADE.name
	$PanelContainer/MarginContainer/VBoxContainer/Description.text = UPGRADE.description
	$PanelContainer/MarginContainer/VBoxContainer/Price.text = "Price: $" + var_to_str(UPGRADE.price)

func _upgrade(player : Player):
	usage += 1
	if usage == 1:
		player.max_hp += UPGRADE.max_health
		player.receive_damage(-UPGRADE.health)
		player.strength += UPGRADE.damage
		if player.crit_chance + UPGRADE.crit_chance <= 1.0:
			player.crit_chance += UPGRADE.crit_chance
		else:
			player.crit_chance = 1.0
		player.crit_mod += UPGRADE.crit_mod
		
		if player.cooldown > UPGRADE.attack_speed:
			player.cooldown -= UPGRADE.attack_speed
		elif player.too_fast == false:
			player.too_fast = true
			player.cooldown = 0.01
		
		player.gold_gain += UPGRADE.gold_gain
		
		# Percentajes
		player.max_hp += player.max_hp * UPGRADE.p_max_health
		player.hp += player.max_hp * UPGRADE.p_health
		player.strength += player.strength * UPGRADE.p_damage
		player.crit_mod += player.crit_mod * UPGRADE.p_crit_mod
		player.cooldown -= player.cooldown * UPGRADE.p_attack_speed
		
		#Closing
		player.gold -= UPGRADE.price
		player.updateUI()
		
		#Disabling
		sprite.hide()
		$"Interaction Component".monitoring = false
		$PanelContainer.hide()

func _on_interaction_component_interacted(user: Player) -> void:
	if user.gold >= UPGRADE.price:
		_upgrade(user)

func _on_interaction_component_body_entered(_body: Node2D) -> void:
	$PanelContainer.show()

func _on_interaction_component_body_exited(_body: Node2D) -> void:
	$PanelContainer.hide()

func _on_visibility_changed() -> void:
	set_collision_layer_value(1,visible)
	$"Interaction Component".monitoring = visible
