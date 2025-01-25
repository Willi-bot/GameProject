class_name Heal
extends Skill

func _init():
	super._init()
	
	name = "Heal"
	description = "Heal za ally :DDD"


func execute(entity: BaseEntity) -> void:
	entity.use_mp(mp_cost)
	var target = await bm.get_player_target()
	var heal_amount = entity.intelligence * 2
	target.entity.heal(heal_amount)
	turn_ended.emit()
