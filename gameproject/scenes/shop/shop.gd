extends Control


func _ready() -> void:
	$ShopBackground/Label.grab_focus()

func _on_label_pressed() -> void:
	Global._show_map()
