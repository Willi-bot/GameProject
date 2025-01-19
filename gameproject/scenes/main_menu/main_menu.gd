extends Control

@onready var continueBtn: Button = $PanelContainer/VBoxContainer/Continue

func _ready() -> void:
	if Global.run_in_progress == false:
		continueBtn.visible = false


func _on_new_game_pressed() -> void:
	Global.start_new_run()


func _on_continue_pressed() -> void:
	Global.continue_run()


func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/settings/settings.tscn")


func _on_quit_pressed() -> void:
	Global.quit_game()
	
