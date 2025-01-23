extends Node


func _ready():
	push_error("This method must be implemented in a subclass")


func resume():
	push_error("This method must be implemented in a subclass")

func pause():
	push_error("This method must be implemented in a subclass")

func _on_close_pressed() -> void:
	get_tree().paused = false
	resume()
	self.visible = false
