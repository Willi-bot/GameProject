extends BaseEntity
class_name EnemyEntity

@export var difficulty: int

func serialize() -> Dictionary:
	var data = super.serialize()
	data["difficulty"] = difficulty
	
	return data



func deserialize(data: Dictionary) -> void:
	super.deserialize(data)
	
	difficulty = data["difficulty"]
	texture = load(get_sprite_path(format_string(name), "front"))
