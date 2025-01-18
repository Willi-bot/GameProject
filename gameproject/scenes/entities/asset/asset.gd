extends Node
class_name Asset


@export var asset_name: String
@export var description: String

var battle_manager

signal turn_ended

func execute(character: Node2D) -> void:
	push_error("This method must be implemented in a subclass")
