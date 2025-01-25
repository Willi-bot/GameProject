extends BattleButton
class_name MainButton

func initialize(battle_manager: BattleManager, name: String, desc: String) -> void:
	bm = battle_manager
	description = desc
	text = name
