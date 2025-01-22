extends Asset
class_name Item

@export var count: int

signal use_item

func _init() -> void:
	type = Asset.Type.ITEM

func execute(entity: BaseEntity) -> void:
	push_error("This method must be implemented in a subclass")


func serialize() -> Dictionary:
	return {"name": name, "count": count}


func deserialize(data: Dictionary) -> void:
	count = data["count"]
