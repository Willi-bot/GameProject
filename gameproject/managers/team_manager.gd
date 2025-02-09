extends Node
class_name TeamManager

func get_active_team():
	return [Global.player] + Global.team


func get_benched_team():
	return Global.bench	


func change_team(active_index: int, inactive_index: int):
	var new_active = null
	var new_bench = null
	
	if len(Global.bench) > inactive_index:
		new_active = Global.bench[inactive_index]
	
	if len(Global.team) > active_index:
		new_bench = Global.team[active_index]

	if new_bench and new_active:
		bench_swap(active_index, new_active, inactive_index, new_bench)
	elif new_bench:
		swap_member_to_bench(new_bench)
	elif new_active:
		swap_member_to_active(new_active)
	
	return		
		

func bench_swap(active_index, new_active, inactive_index, new_bench):
	Global.bench.remove_at(inactive_index)
	Global.bench.insert(inactive_index, new_bench)

	Global.team.insert(active_index, new_active)
	Global.team.erase(new_bench)
	
		
func swap_member_to_bench(new_bench):
	Global.team.erase(new_bench)
	Global.bench.append(new_bench)


func swap_member_to_active(new_active):
	Global.team.append(new_active)
	Global.bench.erase(new_active)
	
