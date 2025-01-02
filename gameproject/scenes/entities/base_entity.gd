extends Resource
class_name BaseEntity


enum EntityType {
	PLAYER,
	ENEMY
}

@export var name: String = ""
@export var type : EntityType
@export var max_hp : int
@export var current_hp : int
@export var damage : int
@export var agility : int

signal turn_ended
signal health_changed

func start_attacking(enemy_target : Node2D) -> void:
	enemy_target.entity.be_damaged(damage)
	turn_ended.emit()
	

func be_damaged(amount : int) -> void:
	
	current_hp = max(0, current_hp - amount)
	health_changed.emit()
