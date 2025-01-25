extends CanvasLayer

@onready var quit_btn: Button = $"Panel Container/HBoxContainer/HBoxContainer/QuitGame"
@onready var new_btn: Button = $"Panel Container/HBoxContainer/HBoxContainer/NewRun"

func _on_visibility_changed() -> void:
	if visible:
		new_btn.grab_focus.call_deferred()
