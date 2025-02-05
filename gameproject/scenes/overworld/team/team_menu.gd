extends "res://scenes/overworld/menu_interface.gd"

@onready var active_bench: HBoxContainer = $Container/Rows/Active/Members
@onready var inactive_bench: HBoxContainer = $Container/Rows/Inactive/Members
@onready var member_node: PackedScene = preload("res://scenes/overworld/team/member_node.tscn")

func resume() -> void:
	clear_benches()


func pause() -> void:
	populate_bench(active_bench, true, Global.team + Global.team)
	populate_bench(inactive_bench, false, Global.team)


func populate_bench(bench: HBoxContainer, active: bool, team: Array[PlayerEntity]) -> void:
	for entity in team:
		var new_member := member_node.instantiate() as PanelContainer
		var texture_rect := new_member.get_node("Sprite") as TextureRect
		
		texture_rect.texture = entity.front_texture
		
		var shader_material := texture_rect.material.duplicate()
		shader_material.set_shader_parameter("active", !active)
		texture_rect.material = shader_material
		
		bench.add_child(new_member)

func clear_benches() -> void:
	for child in active_bench.get_children() + inactive_bench.get_children():
		child.queue_free()
