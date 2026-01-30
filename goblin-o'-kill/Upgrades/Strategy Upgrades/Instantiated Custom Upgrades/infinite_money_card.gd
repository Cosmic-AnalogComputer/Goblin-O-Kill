extends InstantiatedUpgrade

@onready var refund_sound = AudioStreamPlayer.new()

func _ready() -> void:
	player.connect("purchase", on_purchase)
	refund_sound.stream = load("uid://c6qce13ppnnek")
	add_child(refund_sound)

func on_purchase(previous_gold : int) -> void:
	var refund_chance : float = clampf(0.025 * level, 0.025, 0.25)
	
	if randf() <= refund_chance:
		player.gold = previous_gold
		refund_sound.play()
	
	if player.inmortal:
		print(refund_chance)
