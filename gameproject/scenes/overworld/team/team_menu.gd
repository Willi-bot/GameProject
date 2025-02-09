extends "res://scenes/overworld/menu_interface.gd"

@onready var active_bench: HBoxContainer = $Container/Rows/Active/Members
@onready var inactive_bench: HBoxContainer = $Container/Rows/Inactive/Members
@onready var active: PackedScene = preload("res://scenes/overworld/team/active.tscn")
@onready var inactive: PackedScene = preload("res://scenes/overworld/team/inactive.tscn")


func resume() -> void:
	clear_benches()


func pause() -> void:
	populate_active(Global.tm.get_active_team())
	populate_inactive(Global.tm.get_benched_team())

		
func populate_active(team: Array):
	for entity in team:
		active_bench.add_child(get_instance(entity, active))		


func populate_inactive(bench: Array):
	for entity in bench:
		inactive_bench.add_child(get_instance(entity, inactive))	


func get_instance(entity: PlayerEntity, node: PackedScene):
	var scene = node.instantiate()
	
	#scene.texture_normal = entity.front_texture 		
	return scene


func clear_benches() -> void:
	for child in active_bench.get_children() + inactive_bench.get_children():
		child.queue_free()
