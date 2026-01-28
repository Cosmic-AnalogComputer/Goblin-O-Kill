extends Node

var record_path = "user://record.save"

#Game
var record := 0
var current_wave = 0:
	set(value):
		current_wave = value
		if current_wave > record:
			record = current_wave
var wave_mod : float = 0.9
var difficulty = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func save_record():
	var file = FileAccess.open(record_path, FileAccess.WRITE)
	file.store_var(record)

func load_data():
	if FileAccess.file_exists(record_path):
		var file = FileAccess.open(record_path, FileAccess.READ)
		record = file.get_var(record)
	else:
		print("no data")
		record = 0
