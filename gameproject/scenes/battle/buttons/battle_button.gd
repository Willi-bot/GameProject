extends Button
class_name BattleButton


var description: String = ''

func _on_mouse_entered() -> void:
	Global.bm.im.active_btn = self
	_set_active()


func _on_mouse_exited() -> void:
	Global.bm.info_text.text = "Choose your next action"


func _set_active() -> void:
	activate.call_deferred()


func activate():
	set_active_button()


func set_active_button():
	Global.bm.select_icon.visible = true
	Global.bm.select_icon.global_position = global_position
	Global.bm.select_icon.global_position.y += size.y / 2
	Global.bm.info_text.text = description
