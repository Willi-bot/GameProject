extends Resource
class_name BaseEntity

enum Type {
	PLAYER,
	ALLY,
	ENEMY
}

@export var name: String = ""
@export var type : Type

@export var max_hp : int
@export var current_hp : int

@export var max_mp: int
@export var current_mp: int
@export var mp_regen_rate: int = 1

@export var strength : int
@export var intelligence : int
@export var agility : int
@export var luck : int

@export var level : int

@export var skills : Array[Skill] = []

@export var texture: Texture

signal turn_ended
signal health_changed
signal mp_changed
signal death


func start_attacking(enemy_target : Node2D) -> void:
	enemy_target.entity.be_damaged(strength)
	
	turn_ended.emit()
	

func be_damaged(amount : int) -> void:
	current_hp = max(0, current_hp - amount)
	health_changed.emit()
	
	if current_hp == 0:
		death.emit()
	
	
func heal(amount : int) -> void:
	if current_hp < max_hp:
		current_hp = min(current_hp + amount, max_hp)
		health_changed.emit()


func use_mp(amount : int) -> void:
	current_mp = current_mp - amount
	mp_changed.emit()


func regen_mp() -> void:
	current_mp = min(max_mp, current_mp + mp_regen_rate)
	mp_changed.emit()


func serialize() -> Dictionary:
	var data = {
		"name": name,
		"type": type,
		"max_hp": max_hp,
		"current_hp": current_hp,
		"max_mp": max_mp,
		"current_mp": current_mp,
		"mp_regen_rate": mp_regen_rate,
		"strength": strength,
		"luck": luck,
		"intelligence": intelligence,
		"agility": agility,
		"skills": [],
	}
	
	for skill in skills:
		data["skills"].append(skill.name)
	
	return data
	
	
func deserialize(data: Dictionary) -> void:
	var classes = get_skill_classes()
	
	name = data["name"]
	type = data["type"]
	
	level = data.get("level", 1)

	# Scale with level
	calculate_stats(data, level)
	
	current_hp = data.get("current_hp", max_hp)
	max_mp = data["max_mp"]
	current_mp = data.get("current_mp", max_mp)
	mp_regen_rate = data["mp_regen_rate"]
	
	
	for skill_name in data["skills"]:
		var skill = classes[skill_name].new()
		skill._init()
		skills.append(skill)


func calculate_stats(data, level):
	max_hp = data["max_hp"] * level + 10
	strength = data["strength"] * level
	intelligence = data["intelligence"] * level
	agility = data["agility"] * level
	luck = data["luck"] * level


func format_string(input: String) -> String:
	return input.to_lower().replace(" ", "_")


func get_sprite_path(sprite_name, side) -> String:
	return "res://textures/entities/" + sprite_name + "_" + side + ".png"


func get_skill_classes() -> Dictionary:
	var classes = {}
	classes["Fireball"] = Fireball
	classes["Heal"] = Heal
	classes["Sweep"] = Sweep
	return classes
