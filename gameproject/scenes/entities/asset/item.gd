extends Asset
class_name Item

@export var count: int

signal use_item

func execute(character: Node2D) -> void:
	push_error("This method must be implemented in a subclass")
