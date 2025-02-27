class_name Sweep
extends Skill


func _init():
	super._init()
	
	name = "Sweep"
	description = "Attack all enemies dealing physical damage"
	mp_cost = 3

func execute(entity: BaseEntity) -> void:
	super(entity)
	
	entity.use_mp(mp_cost)
	
	var all_enemies = Global.bm.enemy_battlers.duplicate()
	for target in all_enemies:
		target.entity.be_damaged(entity.strength * 10)
	turn_ended.emit()
	
