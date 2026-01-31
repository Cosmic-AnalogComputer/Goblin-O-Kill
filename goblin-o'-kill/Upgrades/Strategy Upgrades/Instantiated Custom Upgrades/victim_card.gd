extends InstantiatedUpgrade

@onready var special_sound = AudioStreamPlayer.new()

func _ready() -> void:
	special_sound.stream = load("uid://c6qce13ppnnek")
	special_sound.bus = "SFX"
	add_child(special_sound)
	if player:
		player.connect("damaged", on_damage)

func on_damage(dmg : int) -> void:
	if randf() <= 0.15 * level:
		player.gold += dmg
		special_sound.play()
