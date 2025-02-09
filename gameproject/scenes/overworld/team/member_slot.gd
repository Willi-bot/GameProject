extends PanelContainer
class_name MemberSlot

@onready var btn: TextureButton = $Button

signal selected



func _on_button_pressed() -> void:
	selected.emit()
