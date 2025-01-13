extends Node

@export var current_level: int = 1
@export var elapsed_time: float = 0.0
@export var gold: int = 42
@export var playerName: String = "Jeremy"
@export var currentHealth: int = 13
@export var maxHealth: int = 78
@export var run_in_progress: bool = false

func _ready() -> void:
	load_state()

func start_new_run() -> void:
	get_tree().paused = false
	current_level = 1
	elapsed_time = 0.0
	run_in_progress = true
	get_tree().change_scene_to_file("res://scenes/overworld/overworld.tscn")


func save_state() -> void:
	var save_data = {
		"current_level": current_level,
		"elapsed_time": elapsed_time,
		"gold": gold,
		"playerName": playerName,
		"currentHealth": currentHealth,
		"maxHealth": maxHealth,
		"run_in_progress": run_in_progress
	}
	var file = FileAccess.open("user://save_game.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()
		print("File saved successfully", save_data)

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
			gold = save_data.get("gold", 42)
			playerName = save_data.get("playerName", "Jeremy")
			currentHealth = save_data.get("currentHealth", 13)
			maxHealth = save_data.get("maxHealth", 78)
			run_in_progress = save_data.get("run_in_progress", false)
			print("State loaded successfully!", save_data)

func quit_game():
	save_state()
	get_tree().quit()
