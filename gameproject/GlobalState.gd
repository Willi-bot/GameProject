extends Node

@export var current_level: int
@export var elapsed_time: float
@export var gold: int 
@export var run_in_progress: bool
@export var player_name: String
@export var current_hp: int
@export var max_hp: int
@export var current_mp: int
@export var max_mp: int
@export var agility: int
@export var damage: int

@export var team = []

var default_state = {
	"current_level": 1,
	"elapsed_time": 0.0,
	"gold": 0,
	"player_name": "Willbert",
	"currentHealth": 80,
	"max_hp": 1200,
	"current_hp": 1200,
	"max_mp": 5,
	"current_mp": 3,
	"agility": 3,
	"damage": 120,
	"run_in_progress": false,
	"team": [
		{
			"name": "Hazard",
			"max_hp": 300,
			"current_hp": 300,
			"max_mp": 5,
			"current_mp": 5,
			"damage": 80,
			"agility": 5,
			"skills": ["whiplash"],
			"sprite": "res://creatures/sprites/hazard.png"
		},
		{
			"name": "Meanion",
			"max_hp": 300,
			"current_hp": 300,
			"max_mp": 5,
			"current_mp": 5,
			"damage": 80,
			"agility": 5,
			"skills": ["whiplash"],
			"sprite": "res://creatures/sprites/meanion.png"
		}
	]
}

func _ready() -> void:
	load_state()

func start_new_run() -> void:
	# Reset global state to default values
	for key in default_state.keys():
		self.set(key, default_state[key])
	get_tree().paused = false
	run_in_progress = true
	get_tree().change_scene_to_file("res://scenes/overworld/overworld.tscn")

func save_state() -> void:
	var save_data = {}
	for key in default_state.keys():
		save_data[key] = self.get(key)
	var file = FileAccess.open("user://save_game.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data))
	file.close()
	print("Succesfully saved state", save_data)

func load_state() -> void:
	if FileAccess.file_exists("user://save_game.json"):
		var file = FileAccess.open("user://save_game.json", FileAccess.READ)
		var json = JSON.new()
		var result = json.parse(file.get_as_text())
		var save_data = json.get_data()
		print("Found existing savefile", save_data)
		file.close()
		for key in default_state.keys():
			if key in save_data:
				self.set(key, save_data[key])

func quit_game() -> void:
	save_state()
	get_tree().quit()

func overwrite_stats(ally_entities: Array) -> void:
	var player = ally_entities.pop_front().entity
	
	max_hp = player["max_hp"]
	current_hp = player["current_hp"]
	max_mp = player["max_mp"]
	current_mp = player["current_mp"]	
	damage = player["damage"]
	agility = player["agility"]
	
	team = []
	
	for team_member in ally_entities:
		var team_entity = team_member.entity

		team.append({
			"max_hp": team_entity["max_hp"],
			"current_hp": team_entity["current_hp"],
			"max_mp": team_entity["max_mp"],
			"current_mp": team_entity["current_mp"],
			"damage": team_entity["damage"],
			"agility": team_entity["agility"],
			"sprite": team_entity["sprite"],
			"skills": team_entity["skills"]
		})
		
	save_state()
