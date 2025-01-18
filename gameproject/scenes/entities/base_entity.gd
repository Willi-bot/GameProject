extends Resource
class_name BaseEntity

@export var name: String = ""
@export var type : int

@export var max_hp : int
@export var current_hp : int

@export var max_mp: int
@export var current_mp: int
@export var mp_regen_rate: int = 1

@export var damage : int
@export var intelligence : int
@export var agility : int
@export var skills : Array = []
@export var sprite: String

signal turn_ended
signal health_changed
signal mp_changed
signal death

func start_attacking(enemy_target : Node2D) -> void:
	enemy_target.entity.be_damaged(damage)
	
	turn_ended.emit()
	

func be_damaged(amount : int) -> void:
	current_hp = max(0, current_hp - amount)
	health_changed.emit()
	
	if current_hp == 0:
		death.emit()
	
	
func heal(amount : int) -> void:
	if current_hp < max_hp:
		current_hp = min(current_hp + amount, max_hp)
		health_changed.emit()


func use_mp(amount : int) -> void:
	current_mp = current_mp - amount
	mp_changed.emit()


func regen_mp() -> void:
	current_mp = min(max_mp, current_mp + mp_regen_rate)
	mp_changed.emit()
	
