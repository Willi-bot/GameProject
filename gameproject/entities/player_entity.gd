extends BaseEntity
class_name PlayerEntity

@export var current_exp : int
@export var required_exp : int

@export var front_texture: Texture

signal level_changed


func serialize() -> Dictionary:
	var data = super.serialize()
	
	data["level"] = level
	data["current_exp"] = current_exp
	
	return data


func deserialize(data: Dictionary) -> void:
	super.deserialize(data)
	
	current_exp = data["current_exp"]
	required_exp = calc_required_exp(level)
	
	var sprite_name = format_string(name) if type != Type.PLAYER else "player"
	
	texture = load(get_sprite_path(sprite_name, "back"))
	front_texture = load(get_sprite_path(sprite_name, "front"))

func assign_exp(exp: int) -> void:
	print("Exp gained: ", exp)
	
	var remaining_exp = exp
	
	while true:
		if current_exp + remaining_exp > required_exp:
			remaining_exp = level_up(remaining_exp)
			print("The players level has changed!")
		else:
			current_exp += exp
			break

func level_up(exp):
	var remaining_exp = exp - (required_exp - current_exp)
	current_exp = 0
	var old_level = level
	level += 1

	max_hp = int((max_hp - 10) / old_level * level) + 10
	strength =  int(strength / old_level * level) 
	intelligence = int(intelligence / old_level * level) 
	agility = int(agility / old_level * level) 
	luck = int(luck / old_level * level) 
	
	
	required_exp = calc_required_exp(level)
	level_changed.emit()
	
	return remaining_exp

func calc_required_exp(level):
	if level < 50:
		return round(pow(level, 3) * (100 - level) / 50)
	elif level < 68:
		return round(pow(level, 3) * (150 - level) / 100)
	elif level < 98:
		return round(pow(level, 3) * (1911 - 10 * level) / 300)
	elif level < 100:
		return round(pow(level, 3) * (160 - level) / 100)
	else:
		push_error("Level is out of the valid range [1 - 99]")
		return 0
