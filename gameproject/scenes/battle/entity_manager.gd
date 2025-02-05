extends Node
class_name EntityManager

var creature_data: Array = Global.load_json("res://entities/entities.json")


func spawn_team(center_pos: Vector2, offset_x: int, root: BattleManager) -> Array[PlayerNode]:
	var nodes: Array[PlayerNode] = []
	var allies = [Global.player] + Global.team
	
	var start_x = center_pos.x - (len(allies) - 1) * offset_x / 2
	var start_pos = Vector2(start_x, center_pos.y)
	
	for ally in allies:
		var instance = Global.PLAYER_SCENE.instantiate()
		var node = _create_node(instance, ally, start_pos)
		
		nodes.append(node)
		root.add_child(node)
		start_pos.x += offset_x
	
	return nodes


func spawn_enemies(center_pos: Vector2, offset_x: int, root: BattleManager) -> Array[EnemyNode]:
	var enemies = _fetch_enemies()

	var start_x = center_pos.x - (len(enemies) - 1) * offset_x / 2
	var start_pos = Vector2(start_x, center_pos.y)

	var nodes: Array[EnemyNode] = []

	for enemy in enemies:
		var instance = Global.ENEMY_SCENE.instantiate()
		var node = _create_node(instance, enemy, start_pos)
		nodes.append(node)
		root.add_child(node)
		start_pos.x += offset_x

	return nodes


func get_action_order(ally_battlers: Array, enemy_battlers: Array):
	var battlers = ally_battlers + enemy_battlers
	battlers.sort_custom(func(a, b): return a.entity.agility > b.entity.agility)
	
	return battlers


func _fetch_enemies() -> Array[EnemyEntity]:
	var difficulty_level = 4 # TODO: Add actual logic for spawning enemies
	var num_creatures = randi() % 4 + 1
	
	var current_difficulty = 0
	var enemies: Array[EnemyEntity] = []
	
	while current_difficulty < difficulty_level and enemies.size() < num_creatures:
		var random_index = randi() % creature_data.size()
		var selected_creature = creature_data[random_index]
		
		selected_creature["level"] = 1
		
		if current_difficulty + selected_creature.difficulty <= difficulty_level:
			var instance = Global.ENEMY_ENTITY.new()
			instance.deserialize(selected_creature)
			enemies.append(instance)
			current_difficulty += selected_creature.difficulty
	
	return enemies


func _create_node(instance: Node, entity: BaseEntity, pos: Vector2) -> Node2D:	
	instance.entity = entity
	instance.get_node("Sprite").texture = entity.texture
	instance.position = pos
	
	return instance
