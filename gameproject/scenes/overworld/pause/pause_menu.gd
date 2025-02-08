extends "res://scenes/overworld/menu_interface.gd"

@onready var animation: AnimationPlayer = $AnimationPlayer

func _ready():
	animation.play("RESET")


func resume():
	animation.play_backwards("blur")
	
	
func pause():
	animation.play("blur")


func _on_resume_pressed() -> void:
	resume()


func _on_restart_pressed() -> void:
	Global.start_new_run()
	resume()


func _on_quit_pressed() -> void:
	Global.save_state()
	Global.quit_game()


func _on_main_menu_pressed() -> void:
	resume()
	_on_close_pressed()
	Global._change_view(Global.MAIN_MENU_SCENE)
