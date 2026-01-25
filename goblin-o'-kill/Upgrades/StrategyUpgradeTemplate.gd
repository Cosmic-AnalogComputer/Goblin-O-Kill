extends Node
# This is not a real upgrade, this is an example for reference.
# Neither is this a template, since these don't require a class or resource

static func apply_upgrade(attack : Punch) -> void:
	attack.damage += 5
	attack.modulate = Color(randf(),randf(),randf())
	attack.scale = Vector2(3,3)
	if randf() < 0.5:
		attack.damage *= 50
		attack.modulate = Color.RED
