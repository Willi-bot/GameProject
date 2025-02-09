extends Node
class_name TeamManager

func get_active_team():
	return [Global.player] + Global.team


func get_benched_team():
	return Global.bench	
