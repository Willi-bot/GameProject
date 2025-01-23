extends "res://scenes/overworld/menu_interface.gd"

@onready var item_node: PackedScene = preload("res://scenes/overworld/inventory/item_node.tscn")
@onready var rows: VBoxContainer = $Container/Rows/ScrollContainer/Rows

func resume() -> void:
	clear_rows()
	
	
func pause() -> void:
	clear_rows()
	
	for item in Global.inventory:
		var instance := item_node.instantiate() as Control
		var container := instance.get_node("Container")
		
		container.get_node("Name").text = item.name
		container.get_node("Count").text = str(item.count)
		container.get_node("Description").text = item.description
		
		var btn := container.get_node("DeleteButton")
		btn.pressed.connect(remove_item.bind(item, instance))
		
		rows.add_child(instance)


func clear_rows():
	for child in rows.get_children():
		child.queue_free()


func remove_item(item: Item, instance: Control) -> void:
	Global.inventory.erase(item)
	instance.queue_free()
