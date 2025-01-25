extends Button
class_name BattleButton

var bm: BattleManager = null
var description: String = ''

func _on_mouse_entered() -> void:
	set_active_button(bm.select_icon, bm.info_text)


func _on_mouse_exited() -> void:
	bm.info_text.text = "Choose your next action"


func _set_active() -> void:
	set_active_button(bm.select_icon, bm.info_text)


func set_active_button(select_icon: TextureRect, info_text: Label):
	select_icon.visible = true
	select_icon.global_position = global_position
	select_icon.position -= Vector2(
		select_icon.size.x * select_icon.scale.x / 4,
		-select_icon.size.y * select_icon.scale.y / 8
	)
	info_text.text = description
