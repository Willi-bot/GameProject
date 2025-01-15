extends Control

@onready var menu_box = $MenuBox
@onready var button_box = menu_box.get_node("ButtonPanel/ButtonBox")

@onready var attack_button = get_button("LeftSide/AttackButton")
@onready var skill_button = get_button("RightSide/SkillButton")
@onready var item_button = get_button("LeftSide/ItemButton")
@onready var neg_button = get_button("RightSide/NegButton")


@onready var info_text : Label = $MenuBox/PanelContainer/InfoText

@onready var skill_menu : CanvasLayer = $MenuBox/ButtonPanel/ButtonBox/SkillMenu
@onready var skill_box : PanelContainer = $MenuBox/ButtonPanel/ButtonBox/SkillMenu/SkillBox
@onready var skill_container : GridContainer =  $MenuBox/ButtonPanel/ButtonBox/SkillMenu/SkillBox/SkillContainer
@onready var target_menu : CanvasLayer = $MenuBox/ButtonPanel/ButtonBox/PlayerTargetMenu
@onready var target_menu_box : PanelContainer = $MenuBox/ButtonPanel/ButtonBox/PlayerTargetMenu/TargetBox
@onready var target_container : HBoxContainer = $MenuBox/ButtonPanel/ButtonBox/PlayerTargetMenu/TargetBox/TargetContainer

@onready var skill_resource : Resource = preload("res://scenes/entities/skill.gd")
@onready var skill_button_resource : Resource = preload("res://scenes/battle/buttons/skill_button.gd")
@onready var skill_button_entity = preload("res://scenes/battle/buttons/skill_button.tscn")
@onready var select_icon: TextureRect = $SelectLayer/SelectIcon

@onready var victory_screen: CanvasLayer = $VictoryScreen
@onready var defeat_screen: CanvasLayer = $DefeatScreen


var player_scene = preload("res://scenes/entities/player_entity.tscn")
var enemy_scene = preload("res://scenes/entities/enemy_entity.tscn")

var all_battlers = []
var ally_battlers = []
var enemy_battlers = []

var current_turn : Node2D
var current_turn_idx : int
var selected_target : Node2D 

var enemies_defeated = false

signal target_chosen(index: int)

func _ready() -> void:
	var enemy_data = load_enemy_data()
	_spawn_entities(enemy_data, Vector2(480, 120), -120, BaseEntity.EntityType.ENEMY)
	
	var ally_data = get_player_data()
	_spawn_entities(ally_data, Vector2(75, 215), 120, BaseEntity.EntityType.PLAYER)

	all_battlers = ally_battlers + enemy_battlers
	all_battlers.sort_custom(func(a, b): return a.entity.agility > b.entity.agility)

	_connect_buttons()
	_connect_ally_callbacks(ally_battlers)
	_connect_enemy_callbacks(enemy_battlers)

	_setup_box(skill_box)
	_setup_box(target_menu_box)

	current_turn = all_battlers[current_turn_idx]
	_update_turn()
	
	_choose_target(enemy_battlers[0])

func _spawn_entities(data, start_pos, offset_x, type):
	var index = 0
	var entity = null
	
	for entity_data in data:
		if type == BaseEntity.EntityType.PLAYER:
			entity = _add_ally_to_battle(entity_data, start_pos)
			ally_battlers.append(entity)
		else:
			entity = _add_enemy_to_battle(entity_data, start_pos)
			enemy_battlers.append(entity)
		
		add_child(entity)

		start_pos.x += offset_x

func _connect_buttons():
	attack_button.pressed.connect(_attack_enemy)
	skill_button.pressed.connect(_choose_skill)
	item_button.pressed.connect(_choose_item)
	neg_button.pressed.connect(_choose_neg_target)


func _connect_ally_callbacks(allies):
	for ally in allies:
		ally.entity.turn_ended.connect(_next_turn)
		ally.entity.death.connect(process_ally_death.bind(ally))

func _connect_enemy_callbacks(enemies):
	for enemy in enemies:
		enemy.entity.turn_ended.connect(_next_turn)
		enemy.deal_damage.connect(_attack_random_ally)
		enemy.target_enemy.connect(_choose_target)
		enemy.entity.death.connect(process_enemy_death.bind(enemy))

func _setup_box(box : Container):
	box.size = $MenuBox.size
	box.size.x /= 2
	box.position = $MenuBox.position


func get_button(name: String) -> Button:
	return button_box.get_node(name)


func get_player_data() -> Array:
	var player_data: Array = []
	var data = null
	
	player_data.append({
		"name": GlobalState.player_name,
		"max_hp": GlobalState.max_hp,
		"current_hp": GlobalState.current_hp,
		"max_mp": GlobalState.max_mp,
		"current_mp": GlobalState.current_mp,
		"damage": GlobalState.damage,
		"intelligence": GlobalState.intelligence,
		"agility": GlobalState.agility,
		"sprite": "res://imgs/player.png",
		"skills": ["Fire"]
	})
	
	for member in GlobalState.team:
		data = {}
		for key in member.keys():
			data[key] = member[key]
		player_data.append(data)

	return player_data


func load_enemy_data() -> Array:
	var file = FileAccess.open("res://creatures/creatures_data.json", FileAccess.READ)
	var json = JSON.new()
	var result = json.parse(file.get_as_text())
	var enemy_data = json.get_data()

	return enemy_data


func _add_enemy_to_battle(character, pos) -> Node2D:
	var instance = enemy_scene.instantiate()
	var sprite = instance.get_node("CharacterSprite")
	sprite.texture_normal = load(character["sprite"])

	for key in character.keys():
		instance.entity.set(key, character[key])
	
	instance.entity.type = BaseEntity.EntityType.ENEMY
	instance.position = pos
	
	return instance

func _add_ally_to_battle(character, pos) -> Node2D:
	var instance = player_scene.instantiate()
	var sprite = instance.get_node("CharacterSprite")
	sprite.texture = load(character["sprite"])

	for key in character.keys():
		instance.entity.set(key, character[key])

	instance.entity.type = BaseEntity.EntityType.PLAYER
	instance.position = pos
	
	return instance


func _attack_enemy() -> void:
	var target = selected_target
	current_turn.entity.start_attacking(target)
		
		
func _choose_skill() -> void:
	select_icon.visible = false
	
	var i = 0
	print("CURRENTLY AVAILABLE SKILLS", current_turn.entity.skills)
	
	for skill in current_turn.entity.skills:
		var new_button = skill_button_entity.instantiate()
		new_button.initialize(skill, self)
		new_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		new_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		new_button.pressed.connect(Callable(new_button, "_on_button_pressed").bind(current_turn))
		new_button.mouse_entered.connect(Callable(new_button, "_on_mouse_entered").bind(select_icon, info_text))
		new_button.mouse_exited.connect(Callable(new_button, "_on_mouse_exited").bind(info_text))
		
		if current_turn.entity.current_mp < new_button.skill.mp_cost:
			new_button.disabled = true

		new_button.skill.turn_ended.connect(_next_turn)
		
		skill_container.add_child(new_button)
		i += 1
		
	while i < 8:
		var invisible_button = Control.new()
		invisible_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		invisible_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		skill_container.add_child(invisible_button)
		i += 1
	
	skill_menu.visible = true
	
	
func _choose_item() -> void:
	print("Choosing an item")
	
	
func _choose_target(target: Node2D) -> void:
	if selected_target:
		selected_target.target_icon.hide()
	selected_target = target
	selected_target.target_icon.show()
	
	
func _choose_neg_target() -> void:
	print("Choose a Negotiation Partner")
	
	
func _attack_random_ally() -> void:
	var ally = ally_battlers[randi_range(0, ally_battlers.size() - 1)]
	current_turn.entity.start_attacking(ally)
	
	
func _next_turn() -> void:
	if current_turn.entity.type == BaseEntity.EntityType.PLAYER:
		current_turn.set_inactive()
	current_turn_idx = (current_turn_idx + 1) % all_battlers.size()
	current_turn = all_battlers[current_turn_idx]
	_update_turn()
	
	
func _update_turn() -> void:
	if current_turn.entity.type == BaseEntity.EntityType.PLAYER:
		attack_button.show()
		current_turn.set_active()
	else:
		attack_button.hide()
		select_icon.hide()
		
	# update amount of mana
	current_turn.entity.regen_mp()
		
	# clear and hide skill menu
	clear_menu(skill_container)
	skill_menu.hide()
	
	# clear and hide target menu
	clear_menu(target_container)
	target_menu.hide()
		
	current_turn.start_turn()
	
	
func clear_menu(container) -> void:
	for n in container.get_children():
		container.remove_child(n)
		n.queue_free()
	target_menu.hide()


func process_enemy_death(enemy):
	enemy_battlers.erase(enemy)
	all_battlers.erase(enemy)
	remove_child(enemy)
	
	if(enemy_battlers.size() == 0):
		victory_screen.show()
		get_tree().paused = true
		return
		
	_choose_target(enemy_battlers[0])
	
	
func process_ally_death(ally):
	var ally_index = ally_battlers.find(ally)

	all_battlers.erase(ally)
	
	if(ally_index == 0):
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


func get_player_target() -> Node2D:
	for character in ally_battlers:
		var target_button = Button.new()
		target_button.text = character.entity.name
		target_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		target_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		target_button.pressed.connect(Callable(self, "_chosen_player").bind(character))
		target_button.mouse_entered.connect(Callable(self, "adjust_select_icon").bind(target_button))
		
		target_container.add_child(target_button)
	
	skill_menu.hide()
	target_menu.show()
	info_text.text = "Choose a player character"
	
	var target = await target_chosen
	
	info_text.text = "Choose your next action"
	
	return target


func _chosen_player(character: Node2D) -> void:
	target_chosen.emit(character)


func _on_continue_game_pressed() -> void:
	GlobalState.overwrite_stats(ally_battlers)
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/overworld/overworld.tscn")


func _on_quit_game_pressed() -> void:
	GlobalState.quit_game()


func _on_new_run_pressed() -> void:
	GlobalState.start_new_run()
