extends Control

@onready var menu_box = $MenuBox
@onready var button_box = menu_box.get_node("ButtonPanel/ButtonBox")
@onready var skill_container = button_box.get_node("SkillMenu/SkillBox/SkillContainer")

@onready var attack_button = get_button("LeftSide/AttackButton")
@onready var skill_button = get_button("RightSide/SkillButton")
@onready var item_button = get_button("LeftSide/ItemButton")
@onready var neg_button = get_button("RightSide/NegButton")


@onready var info_text : Label = $MenuBox/PanelContainer/InfoText

@onready var skill_menu : CanvasLayer = $MenuBox/ButtonPanel/ButtonBox/SkillMenu
@onready var skill_box : PanelContainer = $MenuBox/ButtonPanel/ButtonBox/SkillMenu/SkillBox

@onready var skill_resource : Resource = preload("res://scenes/entities/skill.gd")
@onready var skill_button_resource : Resource = preload("res://scenes/battle/skill_button.gd")
@onready var skill_button_entity = preload("res://scenes/battle/skill_button.tscn")

@onready var select_icon: TextureRect = $SelectLayer/SelectIcon
@onready var target_icon : TextureRect = $TargetIcon

@onready var victory_screen: CanvasLayer = $VictoryScreen
@onready var defeat_screen: CanvasLayer = $DefeatScreen


var player_scene = preload("res://scenes/entities/player_entity.tscn")
var enemy_scene = preload("res://scenes/entities/enemy_entity.tscn")

var all_battlers = []
var ally_battlers = []
var enemy_battlers = []

var current_turn : Node2D
var current_turn_idx : int
var selected_target : int = 0

var enemies_defeated = false

func _ready() -> void:
	_load_battle_entities(get_enemy_data(), BaseEntity.EntityType.ENEMY, Vector2(480, 120), -120, enemy_battlers)
	_load_battle_entities(get_player_data(), BaseEntity.EntityType.PLAYER, Vector2(75, 215), 120, ally_battlers)
	
	all_battlers = ally_battlers + enemy_battlers
	all_battlers.sort_custom(func(a, b): return a.entity.agility > b.entity.agility)

	_connect_buttons()
	_connect_entities(ally_battlers, _next_turn)
	_connect_entities(enemy_battlers, _next_turn, _attack_random_ally, _choose_target)

	_position_target_cursor()
	_setup_skill_box()

	current_turn = all_battlers[current_turn_idx]
	_update_turn()


func _load_battle_entities(data, entity_type, start_pos, offset_x, target_list):
	var char_pos = start_pos
	for character_data in data:
		var character = _add_entity_to_battle(character_data, entity_type, char_pos)
		char_pos.x += offset_x
		target_list.append(character)


func _connect_buttons():
	attack_button.pressed.connect(_attack_enemy)
	skill_button.pressed.connect(_choose_skill)
	item_button.pressed.connect(_choose_item)
	neg_button.pressed.connect(_choose_neg_target)


func _connect_entities(entities, turn_end_callback, damage_callback=null, target_callback=null):
	for entity in entities:
		entity.entity.turn_ended.connect(turn_end_callback)
		if damage_callback:
			entity.deal_damage.connect(damage_callback)
		if target_callback:
			entity.target_enemy.connect(target_callback)


func _position_target_cursor():
	var target = enemy_battlers[selected_target]
	target_icon.scale = target.scale
	target_icon.position = target.position
	var y_offset = target.get_node("CharacterSprite").texture_normal.get_height() / 2
	target_icon.position.y -= (2 * y_offset / 1.3) * target.scale.y


func _setup_skill_box():
	skill_box.size = $MenuBox.size / 2
	skill_box.position = $MenuBox.position



func get_button(name: String) -> Button:
	return button_box.get_node(name)
		
		
func get_player_data() -> Array:
	var player_data: Array = []
	
	# load dummy data -> replace with some global shit
	player_data.append({"name": "Jeremiah", "max_hp": 1000, "current_hp": 1000, "max_mp": 5, "current_mp": 3, "damage": 60, 
						"agility": 4, "sprite": "res://imgs/player.png"})
	player_data.append({"name": "Baldwin", "max_hp": 120, "current_hp": 100, "max_mp": 2, "current_mp": 2, "damage": 30, 
						"agility": 1, "sprite": "res://imgs/player.png"})
	player_data.append({"name": "Denise", "max_hp": 100, "current_hp": 30, "max_mp": 3, "current_mp": 1, "damage": 100, 
						"agility": 2, "sprite": "res://imgs/player.png"})
	
	return player_data


func get_enemy_data() -> Array:
	var enemy_data: Array = []
	
	enemy_data.append({"name": "Gooner", "max_hp": 400, "current_hp": 400, "max_mp": 5, "current_mp": 3, "damage": 70, 
					   "agility": 3, "sprite": "res://imgs/enemy.png"})
	enemy_data.append({"name": "Gooner 2", "max_hp": 300, "current_hp": 300, "max_mp": 5, "current_mp": 3, "damage": 80, 
					   "agility": 5, "sprite": "res://imgs/enemy.png"})
	
	return enemy_data


func _add_entity_to_battle(character, type, pos) -> Node2D:
	var instance = null
	var sprite = null
	
	if type == BaseEntity.EntityType.PLAYER:
		instance = player_scene.instantiate()
		sprite = instance.get_node("CharacterSprite")
		sprite.texture = load(character["sprite"])
	else:
		instance = enemy_scene.instantiate()
		sprite = instance.get_node("CharacterSprite")
		sprite.texture_normal = load(character["sprite"])
	
	for key in character.keys():
		instance.entity.set(key, character[key])
		instance.entity.type = type

	instance.position = pos
	
	add_child(instance)
	
	return instance


func _attack_enemy() -> void:
	var target = enemy_battlers[selected_target]
	current_turn.entity.start_attacking(target)
	
	if(target.entity.current_hp == 0):
		process_enemy_death(target)
	
	
func _choose_skill() -> void:
	select_icon.visible = false
	var list_of_skills = get_skills(current_turn)
	
	var i = 0
	for skill in list_of_skills:
		var new_button = skill_button_entity.instantiate()
		new_button.skill_resource = skill
		new_button.text = skill.name
		new_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		new_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		new_button.pressed.connect(Callable(new_button, "_on_button_pressed").bind(enemy_battlers[selected_target]))
		new_button.mouse_entered.connect(Callable(new_button, "_on_mouse_entered").bind(select_icon))

		skill.turn_ended.connect(_next_turn)
		
		skill_container.add_child(new_button)
		i += 1
		
	while i < 8:
		var invisible_button = Control.new()
		invisible_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		invisible_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		skill_container.add_child(invisible_button)
		i += 1
	
	skill_menu.visible = true
	
	
func get_skills(character) -> Array[Skill]:
	var skill1 = skill_resource.new()
	skill1.name = "Fire"
	
	var skill2 = skill_resource.new()
	skill2.name = "Heal"
	
	var skill3 = skill_resource.new()
	skill3.name = "Ball"
	
	return [skill1, skill2, skill3, skill1, skill2]
	
	
func _choose_item() -> void:
	print("Choosing an item")
	
	
func _choose_target(target: int) -> void:
	selected_target = target
	
	# position target cursor
	var target_position = enemy_battlers[selected_target].position
	var icon_scale = enemy_battlers[selected_target].scale
	target_icon.scale = icon_scale
	target_icon.position = target_position
	var y_offset = enemy_battlers[selected_target].get_node("CharacterSprite").texture_normal.get_height() / 2
	target_icon.position.y -= (2 * y_offset / 1.3) * icon_scale.y
	
	
func _choose_neg_target() -> void:
	print("Choose a Negotiation Partner")
	
	
func _attack_random_ally() -> void:
	var ally = ally_battlers[randi_range(0, ally_battlers.size() - 1)]
	current_turn.entity.start_attacking(ally)
	
	if ally.entity.current_hp == 0:
		process_ally_death(ally)
	
	
func _next_turn() -> void:
	current_turn_idx = (current_turn_idx + 1) % all_battlers.size()
	current_turn = all_battlers[current_turn_idx]
	_update_turn()
	
	
func _update_turn() -> void:
	if current_turn.entity.type == BaseEntity.EntityType.PLAYER:
		attack_button.show()
	else:
		attack_button.hide()
		select_icon.hide()
		
	# clear and hide skill menu
	for n in skill_container.get_children():
		skill_container.remove_child(n)
		n.queue_free() 
	skill_menu.visible = false
		
	current_turn.start_turn()

func process_enemy_death(enemy):
	var enemy_index = enemy_battlers.find(enemy)
	
	enemy_battlers.erase(enemy)
	all_battlers.erase(enemy)
	remove_child(enemy)
	
	if(enemy_battlers.size() == 0):
		target_icon.hide()
		victory_screen.show()
		get_tree().paused = true
		return
		
	_choose_target(enemy_index - 1)
	
func process_ally_death(ally):
	var ally_index = ally_battlers.find(ally)
	
	var entity_index = all_battlers.find(ally)
	all_battlers.remove_at(entity_index)
	
	if(ally_index == 0):
		print("Player has died, game ended")
		get_tree().paused = true
		defeat_screen.show()
	
	ally.sprite.self_modulate = Color(0.2, 0.2, 0.2)
	
	ally_battlers.remove_at(ally_index)

func adjust_select_icon(button: Button) -> void:
	select_icon.show()
	select_icon.global_position = button.global_position

	select_icon.position.y += (select_icon.size.y * select_icon.scale.y) / 8
	select_icon	.position.x -= (select_icon.size.x * select_icon.scale.x) / 4


func _on_attack_button_mouse_entered() -> void:
	info_text.text = "Attack the target"
	adjust_select_icon(attack_button)


func _on_attack_button_mouse_exited() -> void:
	info_text.text = "Choose your next action"


func _on_skill_button_mouse_entered() -> void:
	info_text.text = "Use a Skill"
	adjust_select_icon(skill_button)


func _on_skill_button_mouse_exited() -> void:
	info_text.text = "Choose your next action"

	
func _on_item_button_mouse_entered() -> void:
	info_text.text = "Use Item"
	adjust_select_icon(item_button)


func _on_item_button_mouse_exited() -> void:
	info_text.text = "Choose your next action"
	
	
func _on_neg_button_mouse_entered() -> void:
	info_text.text = "Start Negotiation with a Monster"
	adjust_select_icon(neg_button)


func _on_neg_button_mouse_exited() -> void:
	info_text.text = "Choose your next action"

func _on_continue_game_pressed() -> void:
	# TODO: Process battle results here
	GlobalState.current_level += 1
	
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/overworld/overworld.tscn")


func _on_quit_game_pressed() -> void:
	GlobalState.quit_game()


func _on_new_run_pressed() -> void:
	GlobalState.start_new_run()
