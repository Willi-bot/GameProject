extends Node

var current_view: Control

const OVERWORLD_SCENE := preload("res://scenes/overworld/overworld.tscn")


const BASE_ENTITY: Resource = preload("res://scenes/entities/base_entity.gd")
const PLAYER_SCENE: PackedScene = preload("res://scenes/entities/player_entity.tscn")
const ENEMY_SCENE: PackedScene = preload("res://scenes/entities/enemy_entity.tscn")

# SCENES
const BATTLE_SCENE := preload("res://scenes/battle/battle.tscn")
const CAMPFIRE_SCENE := preload("res://scenes/recovery/recovery.tscn")
const SHOP_SCENE := preload("res://scenes/shop/shop.tscn")
const SUPRISE_SCENE := preload("res://scenes/suprise/suprise.tscn")

const MAIN_MENU := preload("res://scenes/main_menu/main_menu.tscn")

# MISC
@export var current_level: int
@export var run_in_progress: bool
@export var elapsed_time: float
@export var gold: int

# PLAYER
var player_data: Dictionary = {}
@export var player: PlayerEntity

# PLAYER TEAM
var team_data: Array = []
@export var team: Array[PlayerEntity]

# INVENTORY
@export var inventory: Dictionary

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

var default_inventory = {"SmallElixier": 3}

var map_data = null

func _process(delta: float) -> void:
	elapsed_time += delta


func _ready() -> void:
	print("Ready called")
	var successful = load_state()
	
	if successful:
		instantiate_team_entities(player_data, team_data)
		
		overworld = OVERWORLD_SCENE.instantiate()
		
		overworld.map_exited.connect(enter_scene)
		
		add_child(overworld)
		
		overworld.hide_map()

	_change_view(MAIN_MENU)


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
	get_tree().paused = false
	overworld.top_menu
	if current_view:
		remove_child(current_view)
		
	overworld.show_map()
	overworld.unlock_next_rooms()


func start_new_run() -> void:
	if current_view:
		remove_child(current_view)
	
	player = null
	team = []
	
	current_level =	1
	elapsed_time = 0.0
	gold = 0
	
	inventory = default_inventory
	
	instantiate_team_entities(default_player, default_team)
	
	
	get_tree().paused = false
	run_in_progress = true
	
	if overworld:
		overworld.reset()
	else:
		overworld = OVERWORLD_SCENE.instantiate()
		overworld.map_exited.connect(enter_scene)
		add_child(overworld)
	
	overworld.generate_new_map()
	overworld.show_map()


func continue_run():
	if current_view:
		remove_child(current_view)
	overworld.deserialize_map(map_data)
	overworld.show_map()
	

func save_state() -> void:
	var save_data = {}
	save_data["player"] = deserialize_ally(player_data)
	
	var team_data = []
	for team_member in team:
		team_data.append(deserialize_ally(team_member))
	
	save_data["team"] = team_data
	
	save_data["elapsed_time"] = elapsed_time
	save_data["gold"] = current_level
	save_data["current_level"] = current_level
	
	save_data["map_data"] = overworld.serialize_map()
	
	var file = FileAccess.open("user://save_game.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data))
	file.close()


func deserialize_ally(ally):
	var stats = {}
	for key in player_data.keys():
		stats[key] = ally.entity[key]
	return stats


func load_state() -> bool:
	if FileAccess.file_exists("user://save_game.json"):
		var file = FileAccess.open("user://save_game.json", FileAccess.READ)
		var json = JSON.new()
		json.parse(file.get_as_text())
		var save_data = json.get_data()
		
		player_data = save_data["player"]
		team_data = save_data["team"]

		elapsed_time = save_data["elapsed_time"]
		gold = save_data["gold"]
		current_level = save_data["current_level"]
		map_data = save_data["map_data"]

		file.close()
		
		run_in_progress = true
		
		return true
	
	return false

		
func instantiate_team_entities(player_data, team_data):
	player = instantiate_ally(player_data)
	
	for member_data in team_data:
		var member = instantiate_ally(member_data)
		team.append(member)
	
	
func instantiate_ally(data):
	var instance = PLAYER_SCENE.instantiate()	
	instance.entity = BASE_ENTITY.new()
	
	var back_sprite = instance.get_node("BackSprite")
	back_sprite.texture = load(data["sprite"].replace(".png", "_back.png"))
	
	var sprite = instance.get_node("Sprite")

	instance.entity.texture = load(data["sprite"])
	
	sprite.texture = instance.entity.texture 

	for key in data.keys():
		instance.entity.set(key, data[key])
			
	return instance	


func game_over():
	if FileAccess.file_exists("user://save_game.json"):
		DirAccess.remove_absolute("res://save_game.json")
	get_tree().quit()


func quit_game() -> void:
	save_state()
	get_tree().quit()


func enter_scene(type: Room.Type) -> void:
	match type:
		Room.Type.MONSTER:
			_change_view(BATTLE_SCENE)
		Room.Type.SUPRISE:
			_change_view(SUPRISE_SCENE)
		Room.Type.CAMPFIRE:
			_change_view(CAMPFIRE_SCENE)	
		Room.Type.SHOP:
			_change_view(SHOP_SCENE)
		Room.Type.BOSS:
			_change_view(BATTLE_SCENE)	
