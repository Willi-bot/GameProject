extends "res://scenes/overworld/menu_interface.gd"

@onready var active_bench: HBoxContainer = $Container/Rows/Active/Members
@onready var inactive_bench: HBoxContainer = $Container/Rows/Inactive/Members

@onready var member_node: PackedScene = preload("res://scenes/overworld/team/member_node.tscn")

var active_entities
var inactive_entities

func resume():
	_clear_benches()


func pause():
	_populate_bench(active_bench, true, Global.team + Global.team)
	_populate_bench(inactive_bench, false, Global.team)


func _populate_bench(bench: HBoxContainer, active: bool, team: Array[BaseEntity]):
	for entity in team:
		var new_member = member_node.instantiate() as PanelContainer
		bench.add_child(new_member)
		
		var texture_rect = new_member.get_node("Sprite") as TextureRect
		texture_rect.texture = entity.front_texture

		texture_rect.material = texture_rect.material.duplicate()

		texture_rect.material.set_shader_parameter("active", !active)


func _clear_benches():
	for bench in [active_bench, inactive_bench]:
		for child in bench.get_children():
			bench.remove_child(child)
			child.queue_free()
