extends BattleButton
class_name TargetButton


func initialize(name: String) -> void:
	description = "Choose a player character"
	text = name


func _on_mouse_exited() -> void:
	Global.bm.info_text.text = "description"
