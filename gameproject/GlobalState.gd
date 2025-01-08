extends Node

@export var current_level: int = 1
@export var elapsed_time: float = 0.0
@export var run_in_progress: bool = false

func _ready() -> void:
	load_state()

func start_new_run() -> void:
	current_level = 1
	elapsed_time = 0.0
	run_in_progress = true

func save_state() -> void:
	var save_data = {
		"current_level": current_level,
		"elapsed_time": elapsed_time,
		"run_in_progress": run_in_progress
	}
	var file = FileAccess.open("user://save_game.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()
		print("File saved succesfully", save_data)

func load_state() -> void:
	if FileAccess.file_exists("user://save_game.json"):
		var file = FileAccess.open("user://save_game.json", FileAccess.READ)
		if file:
			var json = JSON.new()
			var result = json.parse(file.get_as_text())
			var save_data = json.get_data()
			file.close()
			current_level = save_data.get("current_level", 1)
			elapsed_time = save_data.get("elapsed_time", 0.0)
			run_in_progress = save_data.get("run_in_progress", false)
			print("State loaded succesfully!", save_data)
