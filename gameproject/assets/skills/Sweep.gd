class_name Sweep
extends Skill


func _init():
	super._init()
	
	name = "Sweep"
	description = "Hawk tuah sweep on that thang"
	mp_cost = 3

func execute(entity: BaseEntity) -> void:
	entity.use_mp(mp_cost)
	
	var all_enemies = bm.enemy_battlers.duplicate()
	for target in all_enemies:
		target.entity.be_damaged(220)
	turn_ended.emit()
	
