extends "res://scenes/overworld/menu_interface.gd"

@onready var active_bench: HBoxContainer = $Container/Rows/Active/Members
@onready var active_member: PanelContainer = $Container/Rows/Active/Members/Member
@onready var inactive_bench: HBoxContainer = $Container/Rows/Inactive/Members
@onready var inactive_member: PanelContainer = $Container/Rows/Inactive/Members/Member

var active_entities
var inactive_entities

func _ready():
	self.visible = false
	active_member.hide()
	inactive_member.hide()

func resume():
	self.visible = false
	get_tree().paused = false
	_clear_benches()

func pause():
	_populate_bench(active_bench, active_member, Global.player, Global.team)
	_populate_bench(inactive_bench, inactive_member, Global.player, Global.team)

func _on_close_pressed() -> void:
	resume()


func _populate_bench(bench: HBoxContainer, member_template: PanelContainer, player, team: Array[PlayerEntity]):
	for entity in [player] + team:
		var new_member = member_template.duplicate(true)
		new_member.show()
		var texture_rect = new_member.get_node("Sprite") as TextureRect
		texture_rect.texture = entity.entity.texture
		bench.add_child(new_member)

func _clear_benches():
	for bench in [active_bench, inactive_bench]:
		for child in bench.get_children():
			if child == active_member or child == inactive_member:
				continue
			bench.remove_child(child)
			child.queue_free()
