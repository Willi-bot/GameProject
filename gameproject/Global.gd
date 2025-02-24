extends Node

var current_view: Control = null

var paused = false

const PLAYER_SCENE := preload("res://entities/player/player.tscn")
const ENEMY_SCENE := preload("res://entities/enemy/enemy.tscn")

const PLAYER_ENTITY: Resource = preload("res://entities/player_entity.gd")
const ENEMY_ENTITY: Resource = preload("res://entities/enemy_entity.gd")

# MAIN SCENES
const BATTLE_SCENE := preload("res://scenes/battle/battle.tscn")
const CAMPFIRE_SCENE := preload("res://scenes/recovery/recovery.tscn")
const SHOP_SCENE := preload("res://scenes/shop/shop.tscn")
const SUPRISE_SCENE := preload("res://scenes/suprise/suprise.tscn")


# OTHER SCENES
const SETTINGS_SCENE := preload("res://scenes/settings/settings.tscn")
const MAIN_MENU_SCENE := preload("res://scenes/main_menu/main_menu.tscn")
const OVERWORLD_SCENE := preload("res://scenes/overworld/overworld.tscn")

# MISC
@export var run_in_progress: bool = false
@export var elapsed_time: float = 0.0
@export var gold: int = 0.0
# TODO: Use this once more maps become available
@export var current_map: int = 0
@export var floors_climbed: int = 0	
	
# PLAYER
var player_data: Dictionary = {}
@export var player: PlayerEntity

# PLAYER TEAM
var team_data: Array = []
@export var team: Array[PlayerEntity]

# PLAYER BENCH
var bench_data: Array = []
@export var bench: Array[PlayerEntity]

# INVENTORY
var inventory_data: Array
@export var inventory: Array[Item]

# OVERWORLD
var overworld_data: Dictionary
@export var overworld: Overworld


@export var bm: BattleManager = null
@export var tm: TeamManager = preload("res://managers/team_manager.gd").new()


func _process(delta: float) -> void:
	elapsed_time += delta


func _ready() -> void:
	init_game_state()

	_change_view(MAIN_MENU_SCENE)


func _change_view(scene: PackedScene):
	if current_view:
		remove_child(current_view)
		
	get_tree().paused = false
	var new_view = scene.instantiate()
	
	add_child(new_view)	
	
	current_view = new_view
	if overworld:
		overworld.hide_map()

	return new_view


func _show_map() -> void:
	get_tree().paused = false
	overworld.top_menu
	if current_view:
		remove_child(current_view)
		current_view = null
		
	overworld.show_map()
	overworld.unlock_next_rooms()


func start_new_run() -> void:
	player_data = load_json("res://default_values/player.json")
	
	var team_json = load_json("res://default_values/team.json")
	team_data = team_json["active"]
	bench_data = team_json["bench"]
	
	inventory_data = load_json("res://default_values/inventory.json")
	
	instantiate_game()
	
	if current_view:
		remove_child(current_view)
		current_view = null
		
	overworld.generate_new_map()
	overworld.show_map()

	overworld_data = overworld.serialize()

	get_tree().paused = false
	run_in_progress = true


func continue_run():
	instantiate_game()
	
	if current_view:
		remove_child(current_view)
		current_view = null
	
	overworld.deserialize(overworld_data)
	overworld.show_map()
	

func save_state() -> void:
	var ally_data = {"active": [], "bench": []}
	for t in team:
		ally_data["active"].append(t.serialize())
	
	for b in bench:
		ally_data["bench"].append(b.serialize())


	var items_data = []
	for item in inventory:
		items_data.append(item.serialize())

	var data = {
		"player": player.serialize(),
		"team": ally_data,
		"inventory": items_data,
		"overworld": overworld.serialize(),
		"floors_climbed": floors_climbed,
		"current_map": current_map,
		"elapsed_time": elapsed_time,
		"gold": gold,
	}
	
	var file = FileAccess.open("user://save_game.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()


func init_game_state() -> bool:
	var data = load_json("user://save_game.json")
	
	if !data:
		return false
	
	if !data.has("player") or !data.has("team") or !data.has("overworld"):
		print("Missing required data in save file")
		return false
	
	player_data = data["player"]
	
	var entity_data = data["team"]
	if !entity_data.has("active") or !entity_data.has("bench"):
		print("Missing team data")
		return false
		
	team_data = data["team"]["active"]
	bench_data = data["team"]["bench"]

	elapsed_time = data["elapsed_time"]
	gold = data["gold"]
	overworld_data = data["overworld"]
	inventory_data = data["inventory"]
	floors_climbed = data["floors_climbed"]
	current_map = data["current_map"]
	
	run_in_progress = true

	return true


func load_json(path: String) -> Variant:
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		print("Error opening file")
		return false
	
	var json = JSON.new()
	var parse_result = json.parse(file.get_as_text())
	file.close()
	
	if parse_result != OK:
		print("Error parsing JSON")
		file.close()
		return false
	
	return json.get_data()
	

func instantiate_game():
	instantiate_entities()		
	instantiate_overworld()
	instantiate_inventory()	
		
		
func instantiate_entities():
	player = PLAYER_ENTITY.new()
	player.deserialize(player_data)
	
	team = []
	bench = []
	
	for member_data in team_data:
		var member = PLAYER_ENTITY.new()
		member.deserialize(member_data)
		team.append(member)

	for member_data in bench_data:
		var member = PLAYER_ENTITY.new()
		member.deserialize(member_data)
		bench.append(member)



func instantiate_inventory():
	var classes = get_item_classes()
	
	inventory = []
	
	for item in inventory_data:
		var instance = classes[item.name].new() as Item
		instance._init()
		instance.deserialize(item)
		inventory.append(instance)


func instantiate_overworld():
	overworld = OVERWORLD_SCENE.instantiate()
	overworld.map_exited.connect(enter_scene)
	
	for child in get_children():
		remove_child(child)
	
	add_child(overworld)
	overworld.hide_map()

func _update_item_count(item) -> void:
	item.count -= 1
	if item.count == 0:
		Global.inventory.erase(item)


func game_over():
	if FileAccess.file_exists("user://save_game.json"):
		DirAccess.remove_absolute("res://save_game.json")
	get_tree().quit()


func quit_game() -> void:
	get_tree().quit()


func enter_scene(type: Room.Type) -> void:
	match type:
		Room.Type.MONSTER:
			_change_view(BATTLE_SCENE)
			bm = current_view
		Room.Type.SUPRISE:
			_change_view(SUPRISE_SCENE)
		Room.Type.CAMPFIRE:
			_change_view(CAMPFIRE_SCENE)	
		Room.Type.SHOP:
			_change_view(SHOP_SCENE)
		Room.Type.BOSS:
			_change_view(BATTLE_SCENE)	


func get_item_classes() -> Dictionary:
	var classes = {}
	classes["Small Elixir"] = SmallElixir
	classes["Fairy Tear"] = FairyTear
	return classes
