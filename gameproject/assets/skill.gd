extends Asset
class_name Skill

@export var mp_cost: int


func execute(character: Node2D) -> void:
	push_error("This method must be implemented in a subclass")
