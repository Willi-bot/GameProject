extends CanvasLayer
class_name VictoryScreen

@onready var continue_btn: Button = $"Panel/HBoxContainer/ContinueGame"
@onready var exp_value: Label = $"Panel/HBoxContainer/BattleSummary/Experience/Value"


func _on_visibility_changed() -> void:
	if visible:
		continue_btn.grab_focus.call_deferred()

func show_results(exp: int):
	exp_value.text = str(exp)
	show()
