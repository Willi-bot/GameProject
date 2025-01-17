extends Node

# MISC
@export var current_level: int
@export var run_in_progress: bool
@export var elapsed_time: float
@export var gold: int
# PLAYER
@export var player = {}

# PLAYER TEAM
@export var team : Array

const plane_height = 16 # Scaled up by 80: 2000 / by 65: 1625
const plane_width = 8 # Scaled up by 80: 1280 / by 65:  1040
const node_count = 20
const path_count = 4

var default_player = {
	"name": "Humprey",
	"max_hp": 300,
	"current_hp": 300,
	"max_mp": 5,
	"current_mp": 5,
	"damage": 80,
	"intelligence": 50,
	"agility": 5,
	"skills": ["Sweep"],
	"sprite": "res://imgs/player.png",
	"type":  Entity.Type.PLAYER
}

var default_team = [
	{
			"name": "Hazard",
			"max_hp": 300,
			"current_hp": 300,
			"max_mp": 5,
			"current_mp": 5,
			"damage": 80,
			"intelligence": 50,
			"agility": 5,
			"skills": ["Sweep"],
			"sprite": "res://creatures/sprites/hazard.png",
			"type":  Entity.Type.ALLY
		},
		{
			"name": "Meanion",
			"max_hp": 300,
			"current_hp": 300,
			"max_mp": 5,
			"current_mp": 5,
			"damage": 80,
			"intelligence": 10,
			"agility": 5,
			"skills": ["Heal"],
			"sprite": "res://creatures/sprites/meanion.png",
			"type":  Entity.Type.ALLY
		}
]

func _ready() -> void:
	load_state()

func start_new_run() -> void:
	current_level =	1
	elapsed_time = 0.0
	gold = 0
	
	for key in default_player.keys():
		player[key] = default_player[key]
	
	team = []
	
	for member in default_team:
		var team_member = {}
		for key in member.keys():
			team_member[key] = member[key]
		team.append(team_member)

	get_tree().paused = false
	run_in_progress = true


func save_state() -> void:
	var save_data = {}
	save_data["player"] = player
	save_data["team"] = team
	
	save_data["elapsed_time"] = elapsed_time
	save_data["gold"] = current_level
	save_data["current_level"] = current_level
	
	var file = FileAccess.open("user://save_game.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data))
	file.close()
	print("Succesfully saved state", save_data)

func load_state() -> void:
	if FileAccess.file_exists("user://save_game.json"):
		var file = FileAccess.open("user://save_game.json", FileAccess.READ)
		var json = JSON.new()
		json.parse(file.get_as_text())
		var save_data = json.get_data()
		
		player = save_data["player"]
		team = save_data["team"]

		elapsed_time = save_data["elapsed_time"]
		gold = save_data["gold"]
		current_level = save_data["current_level"]
	
		file.close()
		
		run_in_progress = true

func overwrite_state(allies: Array):
	var keys = player.keys()
	
	var newPlayer = allies.pop_front()
	for key in keys:
		player[key] = newPlayer.entity[key]
		
	var newTeam = []
	for newMember in allies:
		var entity = {}
		for key in player.keys():
			entity[key] = newMember.entity[key]

		newTeam.append(entity)
	team = newTeam

func game_over():
	if FileAccess.file_exists("user://save_game.json"):
		DirAccess.remove_absolute("res://save_game.json")


func quit_game() -> void:
	save_state()
	get_tree().quit()
