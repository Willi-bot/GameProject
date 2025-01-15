extends Node
class_name Skill


@export var skill_name: String
@export var description: String
@export var mp_cost: int

var battle_manager
var character

signal turn_ended

func execute() -> void:
	push_error("This method must be implemented in a subclass")
	
func use_mp() -> void:
	character.entity.use_mp(mp_cost)
