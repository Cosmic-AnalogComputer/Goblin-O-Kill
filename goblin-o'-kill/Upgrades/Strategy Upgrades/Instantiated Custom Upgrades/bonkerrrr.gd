extends InstantiatedUpgrade

@onready var bonk_sound = AudioStreamPlayer.new()

func _ready() -> void:
	player.connect("on_attack", on_attack)
	bonk_sound.stream = load("uid://y6ouxm388f8c")
	bonk_sound.bus = "SFX"
	add_child(bonk_sound)

func on_attack(attack : Punch) -> void:
	attack.connect("hit", on_hit)

func on_hit(enemy : Goblin, attack : Punch) -> void:
	if attack.crit and randf() <= 0.02 * level:
		enemy.receive_damage(attack.applied_damage * 2, Color.RED)
		attack.anim.self_modulate = Color.GOLD
		attack.scale = Vector2(1.1,1.1)
		bonk_sound.play()
		var particle = load("uid://ceiq1o0gfi7jx")
		if not particle in attack.attack_particles:
			attack.attack_particles.append(particle)
