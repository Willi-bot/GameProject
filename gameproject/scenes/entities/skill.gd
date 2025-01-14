extends Node
class_name Skill


@export var skill_name: String
@export var description: String

var battle_manager

signal turn_ended

func execute() -> void:
	push_error("This method must be implemented in a subclass")
