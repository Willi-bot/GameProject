extends "res://scenes/overworld/menu_interface.gd"

@onready var active: HBoxContainer = $Container/Rows/Active/Members
@onready var inactive: HBoxContainer = $Container/Rows/Inactive/Members

var inactive_slot: int = -1
var active_slot: int = -1

func resume() -> void:
	#clear_benches()
	print("Resume")


func pause() -> void:
	populate_benches()


func populate_benches():
	populate_active(Global.player, Global.team)
	populate_inactive(Global.bench)
		
		
func populate_active(player, team: Array):
	var bench_slots = active.get_children()
	
	for slot in bench_slots:
		slot.get_node("Button").texture_normal = null
	
	var player_slot = bench_slots[0] as MemberSlot
	player_slot.btn.texture_normal = player.front_texture	
	
	var team_size = len(team) 
	
	for i in len(bench_slots) - 1:
		var slot = bench_slots[i + 1] as MemberSlot
		
		slot.selected.connect(active_selected.bind(i))
		
		if team_size > i:
			slot.btn.texture_normal = team[i].front_texture	


func populate_inactive(bench: Array):
	var bench_slots = inactive.get_children()
	
	var bench_size = len(bench)
	
	for slot in bench_slots:
		slot.get_node("Button").texture_normal = null
		
	for i in len(bench_slots):
		var slot = bench_slots[i] as MemberSlot
		
		slot.selected.connect(inactive_selected.bind(i))
		
		if bench_size > i:
			slot.btn.texture_normal = bench[i].front_texture	


func active_selected(index: int):
	if inactive_slot != -1:
		Global.tm.change_team(index, inactive_slot)
		_reset_selection()
		return
	
	active_slot = index	


func inactive_selected(index: int):
	if active_slot != -1:
		Global.tm.change_team(active_slot, index)
		_reset_selection()
		return
		
	inactive_slot = index


func _reset_selection():
	inactive_slot = -1
	active_slot = -1
	populate_benches()
