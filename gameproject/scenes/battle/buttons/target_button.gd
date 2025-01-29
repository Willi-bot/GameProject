extends BattleButton
class_name TargetButton


func initialize(battle_manager: BattleManager, name: String) -> void:
	bm = battle_manager
	description = "Choose a player character"
	text = name


func _on_mouse_exited() -> void:
	bm.info_text.text = "description"
