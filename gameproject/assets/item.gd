extends Asset
class_name Item

@export var count: int
@export var texture: Texture

signal use_item

func execute(character: Node2D) -> void:
	push_error("This method must be implemented in a subclass")


func serialize() -> Dictionary:
	return {"count": count, "name": name, "description": description}


func deserialize(data: Dictionary) -> void:
	count = data["count"]
	name = data["name"]
	description = data["description"]
