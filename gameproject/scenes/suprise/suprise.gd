extends Control

func _ready() -> void:
	$ShopBackground/Label.grab_focus()

func _on_button_pressed() -> void:
	Global._show_map()
