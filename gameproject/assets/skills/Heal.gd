class_name Heal
extends Skill

func _init():
	name = "Heal"
	description = "Heal za ally :DDD"


func execute(character: Node2D) -> void:
	character.entity.use_mp(mp_cost)
	var target = await battle_manager.get_player_target()
	var heal_amount = character.entity.intelligence * 2
	target.entity.heal(heal_amount)
	turn_ended.emit()
