extends Node

var current_view: Control

const OVERWORLD_SCENE := preload("res://scenes/overworld/overworld.tscn")

# SCENES
const BATTLE_SCENE := preload("res://scenes/battle/battle.tscn")
const CAMPFIRE_SCENE := preload("res://scenes/recovery/recovery.tscn")
const SHOP_SCENE := preload("res://scenes/shop/shop.tscn")
const TREASURE_SCENE := preload("res://scenes/suprise/suprise.tscn")

@export var MAIN_MENU := preload("res://scenes/main_menu/main_menu.tscn")

# MISC
@export var current_level: int
@export var run_in_progress: bool
@export var elapsed_time: float
@export var gold: int
# PLAYER
@export var player = {}

# PLAYER TEAM
@export var team : Array

@export var overworld: Overworld

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

var map_data = null

func _ready() -> void:
	var succesfull = load_state()
	
	if succesfull:
		overworld = OVERWORLD_SCENE.instantiate()
		
		overworld.map_exited.connect(enter_scene)
		
		add_child(overworld)
		
		overworld.hide_map()


func _change_view(scene: PackedScene):
	
	if current_view:
		remove_child(current_view)
		
	get_tree().paused = false
	var new_view = scene.instantiate()
	add_child(new_view)	
	
	current_view = new_view
	overworld.hide_map()

	return new_view


func _show_map() -> void:
	if current_view:
		remove_child(current_view)
		
	overworld.show_map()
	overworld.unlock_next_rooms()


func start_new_run() -> void:
	if overworld:
		overworld.reset()
	else:
		overworld = OVERWORLD_SCENE.instantiate()
		overworld.map_exited.connect(enter_scene)
		add_child(overworld)
		
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
	
	overworld.generate_new_map()
	overworld.show_map()


func continue_run():
	overworld.deserialize_map(map_data)
	overworld.show_map()
	

func save_state() -> void:
	var save_data = {}
	save_data["player"] = player
	save_data["team"] = team
	
	save_data["elapsed_time"] = elapsed_time
	save_data["gold"] = current_level
	save_data["current_level"] = current_level
	
	save_data["map_data"] = overworld.serialize_map()
	
	var file = FileAccess.open("user://save_game.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data))
	file.close()
	print("Succesfully saved state!")


func load_state() -> bool:
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
		map_data = save_data["map_data"]

		file.close()
		
		run_in_progress = true
		
		return true
	
	return false
		
		

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


func enter_scene(type: Room.Type) -> void:
	print("We enter the scene: ", type)
	match type:
		Room.Type.MONSTER:
			_change_view(BATTLE_SCENE)
		Room.Type.TREASURE:
			_change_view(TREASURE_SCENE)
		Room.Type.CAMPFIRE:
			_change_view(CAMPFIRE_SCENE)	
		Room.Type.SHOP:
			_change_view(SHOP_SCENE)
		Room.Type.BOSS:
			_change_view(BATTLE_SCENE)	
