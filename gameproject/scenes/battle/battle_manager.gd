extends Control

@onready var attack_button : Button = $MenuBox/ButtonBox/LeftSide/AttackButton
@onready var skill_button : Button = $MenuBox/ButtonBox/RightSide/SkillButton
@onready var item_button : Button = $MenuBox/ButtonBox/LeftSide/ItemButton
@onready var neg_button : Button = $MenuBox/ButtonBox/RightSide/NegButton

@onready var info_text : Label = $MenuBox/PanelContainer/InfoText

@onready var target_icon : TextureRect = $TargetIcon

var player_scene = preload("res://scenes/entities/player_entity.tscn")
var enemy_scene = preload("res://scenes/entities/enemy_entity.tscn")

var all_battlers = []
var player_battlers = []
var enemy_battlers = []

var current_turn : Node2D
var current_turn_idx : int
var selected_target : int = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# load player character and enemies
	# load enemy data from globals or sth
	var enemy_data = get_enemy_data()
	var char_pos = Vector2(900, 225)
	for enemy_character in enemy_data:
		var character = add_char_to_battle(enemy_character, BaseEntity.EntityType.ENEMY, char_pos)
		char_pos.x -= 300
		enemy_battlers.append(character)
	
	# load player data from globals or sth
	var player_data = get_player_data()
	char_pos = Vector2(150, 450)
	for player_character in player_data:
		var character = add_char_to_battle(player_character, BaseEntity.EntityType.PLAYER, char_pos)
		char_pos.x += 300
		player_battlers.append(character)
	
	all_battlers.append_array(player_battlers)
	all_battlers.append_array(enemy_battlers)
	all_battlers.sort_custom(func(a, b): return a.entity.agility > b.entity.agility)
	
	attack_button.pressed.connect(_perform_attack)
	skill_button.pressed.connect(_choose_skill)
	item_button.pressed.connect(_choose_item)
	neg_button.pressed.connect(_choose_neg_target)
	
	
	for p in player_battlers:
		p.entity.turn_ended.connect(_next_turn)
		
	for e in enemy_battlers:
		e.list_id = enemy_battlers.find(e, 0)
		e.deal_damage.connect(_attack_random_battler)
		e.entity.turn_ended.connect(_next_turn)
		e.target_enemy.connect(_choose_target)
		
	# position target cursor
	var target_position = enemy_battlers[selected_target].position
	target_icon.position = target_position
	target_icon.position.y -= enemy_battlers[selected_target].get_node("Sprite").texture_normal.get_height() / 1.15
	target_icon.position.x -= target_icon.size.x
	
	
	current_turn = all_battlers[current_turn_idx]
	_update_turn()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func get_player_data() -> Array:
	var player_data: Array = []
	
	# load dummy data -> replace with some global shit
	player_data.append({"name": "Jeremiah", "max_hp": 200, "current_hp": 200, "damage": 60, 
						"agility": 4, "sprite": "res://imgs/player.png"})
	player_data.append({"name": "Baldwin", "max_hp": 350, "current_hp": 330, "damage": 30, 
						"agility": 1, "sprite": "res://imgs/player.png"})
	player_data.append({"name": "Denise", "max_hp": 150, "current_hp": 100, "damage": 100, 
						"agility": 2, "sprite": "res://imgs/player.png"})
	
	return player_data


func get_enemy_data() -> Array:
	var enemy_data: Array = []
	
	enemy_data.append({"name": "Gooner", "max_hp": 400, "current_hp": 400, "damage": 70, 
					   "agility": 3, "sprite": "res://imgs/enemy.png"})
	enemy_data.append({"name": "Gooner 2", "max_hp": 300, "current_hp": 300, "damage": 80, 
					   "agility": 5, "sprite": "res://imgs/enemy.png"})
	
	return enemy_data


func add_char_to_battle(character, type, pos) -> Node2D:
	var instance = null
	
	if type == BaseEntity.EntityType.PLAYER:
		instance = player_scene.instantiate()
	else:
		instance = enemy_scene.instantiate()
	
	instance.entity.name = character["name"]
	instance.entity.type = type
	instance.entity.max_hp = character["max_hp"]
	instance.entity.current_hp = character["current_hp"]
	instance.entity.damage = character["damage"]
	instance.entity.agility = character["agility"]
	
	# TODO
	# var sprite = instance.get_node("CharacterSprite")
	# sprite.texture.path = player_character["Sprite"]
	
	instance.position = pos
	
	add_child(instance)
	
	return instance


func _perform_attack() -> void:
	var target = enemy_battlers[selected_target]
	print(enemy_battlers)
	current_turn.entity.start_attacking(target)
	print("Enemies damaged")
	for e in enemy_battlers:
		print(e.list_id)
		print(e.entity.current_hp)
		print(e.entity.max_hp)
	
	
func _choose_skill() -> void:
	print("Choosing a skill")
	
	
	
func _choose_item() -> void:
	print("Choosing an item")
	
	
func _choose_target(target: int) -> void:
	selected_target = target
	
	# position target cursor
	var target_position = enemy_battlers[selected_target].position
	target_icon.position = target_position
	target_icon.position.y -= enemy_battlers[selected_target].get_node("Sprite").texture_normal.get_height() / 1.15
	target_icon.position.x -= target_icon.size.x
	
	
func _choose_neg_target() -> void:
	print("Choose a Negotiation Partner")
	
	
func _attack_random_battler() -> void:
	var target = player_battlers[randi_range(0, player_battlers.size() - 1)]
	current_turn.entity.start_attacking(target)
	
	
func _next_turn() -> void:
	if has_battle_ended():
		pass # implement end of battle
	
	current_turn_idx = (current_turn_idx + 1) % all_battlers.size()
	current_turn = all_battlers[current_turn_idx]
	_update_turn()
	
	
func _update_turn() -> void:
	if current_turn.entity.type == BaseEntity.EntityType.PLAYER:
		attack_button.show()
	else:
		attack_button.hide()
		
	current_turn.start_turn()


func has_battle_ended() -> bool:
	return false


func _on_attack_button_mouse_entered() -> void:
	info_text.text = "Attack the target"


func _on_attack_button_mouse_exited() -> void:
	info_text.text = "Choose your next action"


func _on_skill_button_mouse_entered() -> void:
	info_text.text = "Use a Skill"


func _on_skill_button_mouse_exited() -> void:
	info_text.text = "Choose your next action"
	
	
func _on_item_button_mouse_entered() -> void:
	info_text.text = "Use Item"


func _on_item_button_mouse_exited() -> void:
	info_text.text = "Choose your next action"
	
	
func _on_neg_button_mouse_entered() -> void:
	info_text.text = "Start Negotiation with a Monster"


func _on_neg_button_mouse_exited() -> void:
	info_text.text = "Choose your next action"
