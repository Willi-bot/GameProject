extends Resource
class_name Asset

enum Type {
	SKILL,
	ITEM
}

@export var name: String
@export var description: String
@export var type: Type

var battle_manager: BattleManager

signal turn_ended

func _init():
	push_error("This method must be implemented in a subclass")

func execute(entity: BaseEntity) -> void:
	push_error("This method must be implemented in a subclass")


func serialize() -> Dictionary:
	push_error("This method must be implemented in a subclass")
	return {}


func deserialize(data: Dictionary) -> void:
	push_error("This method must be implemented in a subclass")
	
