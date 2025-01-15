extends Node
class_name Skill


@export var skill_name: String
@export var description: String
@export var mp_cost: int

var battle_manager

signal turn_ended

func execute(character: Node2D) -> void:
	push_error("This method must be implemented in a subclass")
