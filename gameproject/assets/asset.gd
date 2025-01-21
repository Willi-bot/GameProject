extends Resource
class_name Asset


@export var name: String
@export var description: String

var battle_manager

signal turn_ended

func _init():
	push_error("This method must be implemented in a subclass")

func execute(character: Node2D) -> void:
	push_error("This method must be implemented in a subclass")


func serialize() -> Dictionary:
	push_error("This method must be implemented in a subclass")
	return {}


func deserialize(data: Dictionary) -> void:
	push_error("This method must be implemented in a subclass")
	
