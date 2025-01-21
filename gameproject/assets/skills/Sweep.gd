class_name Sweep
extends Skill


func _init():
	name = "Sweep"
	description = "Hawk tuah sweep on that thang"


func execute(character: Node2D) -> void:
	character.entity.use_mp(mp_cost)
	var all_enemies = battle_manager.enemy_battlers.duplicate()
	for target in all_enemies:
		target.entity.be_damaged(220)
	turn_ended.emit()
	
