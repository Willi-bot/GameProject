extends CanvasLayer

@onready var continue_btn: Button = $"Panel Container/HBoxContainer/ContinueGame"



func _on_visibility_changed() -> void:
	if visible:
		continue_btn.grab_focus.call_deferred()
