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
	resume()
	get_tree().reload_current_scene()


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_close_pressed() -> void:
	resume()
