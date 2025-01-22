class_name Fireball
extends Skill


func _init():
	super._init()
	
	name = "Fireball"
	description = "Shoot za fireball"
	mp_cost = 2

func execute(entity: BaseEntity) -> void:
	entity.use_mp(mp_cost)
	var target = battle_manager.selected_target
	var damage = entity.intelligence * 2
	entity.be_damaged(damage)
	turn_ended.emit()
