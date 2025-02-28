class_name Sweep
extends Skill

var target_count: int = 0
var enemy_count: int = 0

func _init():
	super._init()
	
	name = "Sweep"
	description = "Attack all enemies dealing physical damage"
	mp_cost = 3

func execute(entity: BaseEntity) -> void:
	super(entity)
	selection_finished.emit()

	print("THIS is emited")
	
	entity.use_mp(mp_cost)
	
	target_count = 0
	
	var all_enemies = Global.bm.enemy_battlers.duplicate()
	
	enemy_count = len(all_enemies)
	
	for target in all_enemies:
		target.entity.damage_processed.connect(increment_state)
	
	for target in all_enemies:
		target.entity.be_damaged(entity.strength * 10, true)
	
	
func increment_state():
	target_count += 1
	
	if target_count == enemy_count:
		turn_ended.emit()
