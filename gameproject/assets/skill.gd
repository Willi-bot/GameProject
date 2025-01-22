extends Asset
class_name Skill

@export var mp_cost: int

func _init() -> void:
	type = Asset.Type.SKILL

func execute(entity: BaseEntity) -> void:
	push_error("This method must be implemented in a subclass")
