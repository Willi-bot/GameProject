class_name Fireball
extends Skill


func _init():
	name = "Sweep"
	description = "Shoot za fireball"


func execute(character: Node2D) -> void:
	character.entity.use_mp(mp_cost)
	var target = battle_manager.selected_target
	var damage = character.entity.intelligence * 2
	target.entity.be_damaged(damage)
	turn_ended.emit()
