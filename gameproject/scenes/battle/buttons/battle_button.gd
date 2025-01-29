extends Button
class_name BattleButton

var bm: BattleManager = null
var description: String = ''

func _on_mouse_entered() -> void:
	bm.active_btn = self
	_set_active()


func _on_mouse_exited() -> void:
	bm.info_text.text = "Choose your next action"


func _set_active() -> void:
	activate.call_deferred()


func activate():
	set_active_button(bm.select_icon, bm.info_text)

func set_active_button(select_icon: Sprite2D, info_text: Label):
	select_icon.visible = true
	select_icon.global_position = global_position
	select_icon.global_position.y += size.y / 2
	info_text.text = description
