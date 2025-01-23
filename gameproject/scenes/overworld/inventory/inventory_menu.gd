extends "res://scenes/overworld/menu_interface.gd"

@onready var item_node: PackedScene = preload("res://scenes/overworld/inventory/item_node.tscn")
@onready var rows: VBoxContainer = $Container/Rows/ScrollContainer/Rows

var itemNodes: Array[Node]

signal closed 

func resume():
	for child in rows.get_children():
		rows.remove_child(child)
	
func pause():
	for item in Global.inventory + Global.inventory + Global.inventory + Global.inventory:
		var instance = item_node.instantiate()
		
		instance.get_node("Container/Name").text = item.name
		instance.get_node("Container/Count").text = str(item.count)
		instance.get_node("Container/Description").text = item.description
		
		var btn = instance.get_node("Container/DeleteButton")
		btn.pressed.connect(remove_item.bind(item, instance))
		
		rows.add_child(instance)


func remove_item(item: Item, instance):
	Global.inventory.erase(item)
	rows.remove_child(instance)
