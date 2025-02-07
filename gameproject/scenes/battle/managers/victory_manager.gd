extends Node
class_name VictoryManager

@export var earned_exp: int = 0

func calculate_experience(enemies: Array[EnemyEntity]):
	var difficulty_sum = 0
	var level_sum = 0
	
	for enemy in enemies:
		difficulty_sum += enemy.difficulty
		level_sum += enemy.level

	earned_exp = round(difficulty_sum * level_sum)

	return


func distribute_exp(players: Array[PlayerNode])	:
	var exp_candidates: Array[PlayerNode] = []
	
	for player in players:
		if player.entity.current_hp:
			exp_candidates.append(player)
		
	var player_exp = round(earned_exp / len(exp_candidates))
	
	for player in exp_candidates:
		player.entity.assign_exp(player_exp)
