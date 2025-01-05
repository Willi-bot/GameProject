extends "res://scenes/overworld/menu_interface.gd"

func _ready():
	self.visible = false

func resume():
	self.visible = false
	get_tree().paused = false
	
func pause():
	self.visible = true
	get_tree().paused = true	



func _on_close_pressed() -> void:
	resume()
