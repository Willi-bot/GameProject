extends MenuBar


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_items_pressed() -> void:
	print("Items button pressed")


func _on_team_pressed() -> void:
	print("Teams button pressed")


func _on_settings_pressed() -> void:
	print("Settings button pressed")
