extends Resource
class_name Skill


@export var name: String

signal turn_ended

func start_attacking(enemy_target : Node2D) -> void:
	print("doing alot of damage")
	var damage = randi_range(20, 100)
	enemy_target.entity.be_damaged(damage)
	turn_ended.emit()
