extends "res://scenes/overworld/menu_interface.gd"

@onready var animation: AnimationPlayer = $AnimationPlayer

func _ready():
	self.visible = false
	animation.play("RESET")

func resume():
	self.visible = false
	get_tree().paused = false

	animation.play_backwards("blur")
	
func pause():
	self.visible = true
	get_tree().paused = true	

	animation.play("blur")

func _on_resume_pressed() -> void:
	resume()

func _on_restart_pressed() -> void:
	Global.start_new_run()
	resume()

func _on_quit_pressed() -> void:
	Global.save_state()
	Global.quit_game()

func _on_close_pressed() -> void:
	resume()


func _on_main_menu_pressed() -> void:
	resume()
	Global._change_view(Global.MAIN_MENU_SCENE)
