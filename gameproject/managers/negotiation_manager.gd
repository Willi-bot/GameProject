extends Node
class_name NegotiationManager


var negotiation: Negotiation
var negotiation_chance: Dictionary = {}
var negotiation_target: EnemyNode


func prepare_negotiation() -> void:
	for enemy in Global.bm.enemy_battlers:
		var success_chance: float = 0.5 # replace with standard value for each monster
		# consider level diff
		success_chance -= max(0, (enemy.entity.level - Global.player.level) * 0.10)
		# consider damage
		success_chance -= 0.5 * (1. - (float(enemy.entity.current_hp) / float(enemy.entity.max_hp)))
		
		negotiation_chance[enemy] = success_chance
		
		# set outline color for each enemy
		enemy.set_shader_color(Color(max(0., 1. - success_chance - 0.15), min(1., success_chance + 0.15), 0.))
		
		enemy.target_enemy.connect(start_negotiation)
	
	
func start_negotiation(enemy) -> void:
	negotiation_target = enemy
	negotiation = load("res://scenes/battle/negotiation/Negotiation.tscn").instantiate()
	negotiation.set_success_chance(negotiation_chance[enemy])
	negotiation.negotiation_end.connect(_terminate_negotiation)
	Global.bm.add_child(negotiation)


func _terminate_negotiation(success: bool) -> void:
	for enemy in Global.bm.enemy_battlers:
		enemy.set_shader_color(Color(0., 0., 0.))
		
	Global.bm.remove_child(negotiation)
	
	Global.bm.select_icon.show()
	Global.bm.im.change_active_menu(Global.bm.main_box)
	
	if success:
		# Add enemy to party
		# Need a Team Manager to pass this shit to
		pass
	
	Global.bm._next_turn()
