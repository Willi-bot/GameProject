class_name BattleManager
extends Control

@onready var menu_box = $MenuBox
@onready var button_panel = $MenuBox/ButtonPanel
@onready var main_box = $MenuBox/ButtonPanel/ButtonBox

@onready var info_text : Label = $MenuBox/PanelContainer/InfoText

@onready var skill_menu : CanvasLayer = $MenuBox/ButtonPanel/SkillMenu
@onready var skill_box : PanelContainer = skill_menu.get_node("SkillBox")
@onready var skill_container : GridContainer = $MenuBox/ButtonPanel/SkillMenu/SkillBox/SkillContainer
@onready var item_menu : CanvasLayer = $MenuBox/ButtonPanel/ItemMenu
@onready var item_box : PanelContainer = $MenuBox/ButtonPanel/ItemMenu/ItemBox
@onready var item_container : GridContainer = $MenuBox/ButtonPanel/ItemMenu/ItemBox/ItemContainer
@onready var target_menu : CanvasLayer = $MenuBox/ButtonPanel/PlayerTargetMenu
@onready var target_menu_box : PanelContainer = $MenuBox/ButtonPanel/PlayerTargetMenu/TargetBox
@onready var target_container : GridContainer = $MenuBox/ButtonPanel/PlayerTargetMenu/TargetBox/TargetContainer

@onready var skill_resource : Resource = preload("res://assets/skill.gd")
@onready var item_resource : Resource = preload("res://assets/item.gd")
@onready var main_button: PackedScene = preload("res://scenes/battle/buttons/main_button.tscn")
@onready var asset_button: PackedScene = preload("res://scenes/battle/buttons/asset_button.tscn")
@onready var target_button: PackedScene = preload("res://scenes/battle/buttons/target_button.tscn")
@onready var select_icon: TextureRect = $SelectLayer/SelectIcon

@onready var victory_screen: CanvasLayer = $VictoryScreen
@onready var defeat_screen: CanvasLayer = $DefeatScreen

var enemy_scene = preload("res://entities/enemy/enemy.tscn")

var item_btn = null
var neg_btn = null

var battlers = []
var ally_battlers = []
var enemy_battlers = []

var current_turn : Node2D
var current_turn_idx : int

var selected_target : Node2D 
var ally_turn: bool = true
var game_over: bool = false

# Used for keyboard selection
var btn_dict = {}
var btn_index = Vector2.ZERO
var active_btn: BattleButton = null

signal target_chosen(index: int)

func _ready() -> void:
	game_over = false
	
	var enemy_data = load_enemy_data()
	_spawn_entity_nodes(enemy_data, Vector2(480, 120), -120)
	
	var ally_data = [Global.player] + Global.team
	_spawn_entity_nodes(ally_data, Vector2(75, 215), 120)

	battlers = ally_battlers + enemy_battlers
	battlers.sort_custom(func(a, b): return a.entity.agility > b.entity.agility)

	_connect_callbacks()
	_create_main_buttons()


	_setup_boxes([skill_box, item_box, target_menu_box])

	current_turn = battlers[current_turn_idx]
	_update_turn()
	
	_choose_target(enemy_battlers[0])

	change_active_menu(main_box)


func _spawn_entity_nodes(entities, start_pos, offset_x):
	var index = 0
	var scene_node = null
	
	for entity in entities:
		scene_node = _add_entity_to_battle(entity, start_pos)
		
		if entity.type == BaseEntity.Type.ENEMY:
			enemy_battlers.append(scene_node)
		else:
			ally_battlers.append(scene_node)
		add_child(scene_node)
		start_pos.x += offset_x


func _connect_callbacks():
	for ally in ally_battlers:
		ally.entity.turn_ended.connect(_next_turn)
		ally.entity.death.connect(process_ally_death.bind(ally))
		
	for enemy in enemy_battlers:
		enemy.entity.turn_ended.connect(_next_turn)
		enemy.deal_damage.connect(_attack_random_ally)
		enemy.target_enemy.connect(_choose_target)
		enemy.entity.death.connect(process_enemy_death.bind(enemy))


func _setup_boxes(boxes : Array[Container]):
	for box in boxes:
		box.size = $MenuBox.size
		box.size.x /= 2
		box.position = $MenuBox.position


func get_button(name: String) -> Button:
	return main_box.get_node(name)


func load_enemy_data() -> Array[BaseEntity]:
	var file = FileAccess.open("res://entities/entity_data.json", FileAccess.READ)
	var json = JSON.new()
	json.parse(file.get_as_text())
	
	var enemies = [] as Array[BaseEntity]

	for creature in json.get_data():
		var instance = Global.BASE_ENTITY.new() as BaseEntity
		instance.deserialize(creature)
		enemies.append(instance)
	
	return enemies


func _add_entity_to_battle(entity: BaseEntity, pos) -> Node2D:	
	var isAlly = entity.type != BaseEntity.Type.ENEMY
	var scene = Global.PLAYER_SCENE if isAlly else Global.ENEMY_SCENE
	var instance = scene.instantiate()
	instance.entity = entity
	
	var sprite = instance.get_node("Sprite")
	sprite.texture = entity.back_texture if isAlly else entity.front_texture
	
	instance.position = pos
	
	return instance


func _attack_enemy() -> void:
	if game_over:
		return
	current_turn.entity.start_attacking(selected_target)
		
		
func _choose_skill() -> void:
	if game_over:
		return
	select_icon.visible = false
	
	clear_menu(skill_container)
	
	for skill in current_turn.entity.skills:
		skill_container.add_child(_create_asset_button(skill))

	skill_menu.show()
	change_active_menu(skill_container)
	
	
func _choose_item() -> void:
	select_icon.visible = false
	
	clear_menu(item_container)
	
	for item in Global.inventory:
		item_container.add_child(_create_asset_button(item))

	item_menu.show()
	change_active_menu(item_container)


func _create_main_buttons():
	var attack_btn = main_button.instantiate() as MainButton
	attack_btn.initialize(self, "Attack", "Attack an enemy")	
	main_box.add_child(attack_btn)
	attack_btn.pressed.connect(_attack_enemy)
	
	var skill_btn = main_button.instantiate() as MainButton
	skill_btn.initialize(self, "Skills", "Choose a skill")	
	main_box.add_child(skill_btn)
	skill_btn.pressed.connect(_choose_skill)
	
	item_btn = main_button.instantiate() as MainButton
	item_btn.initialize(self, "Item", "Choose an item")	
	main_box.add_child(item_btn)
	item_btn.pressed.connect(_choose_item)
	
	neg_btn = main_button.instantiate() as MainButton
	neg_btn.initialize(self, "Negotiate", "Negotiate with enemy")	
	main_box.add_child(neg_btn)
	# TODO: neg_btn.pressed.connect()

	
func _create_asset_button(asset: Asset) -> Button:
	var btn = asset_button.instantiate() as AssetButton
	btn.initialize(asset, self)
	
	btn.pressed.connect(Callable(btn, "_on_button_pressed").bind(current_turn.entity))
	btn.mouse_entered.connect(Callable(btn, "_on_mouse_entered"))
	btn.mouse_exited.connect(Callable(btn, "_on_mouse_exited"))
	btn.asset.turn_ended.connect(_next_turn)
	
	return btn
	
	
func _choose_target(target: Node2D) -> void:
	if selected_target:
		selected_target.target_icon.hide()
	selected_target = target
	selected_target.target_icon.show()
	
	
func _choose_neg_target() -> void:
	print("Choose a Negotiation Partner")
	
	
func _attack_random_ally() -> void:
	if game_over:
		return
	await get_tree().create_timer(1).timeout 
	var ally = ally_battlers[randi_range(0, ally_battlers.size() - 1)]
	current_turn.entity.start_attacking(ally)
	
	
func _next_turn() -> void:
	if game_over:
		return

	current_turn.set_inactive()
	current_turn_idx = (current_turn_idx + 1) % battlers.size()
	current_turn = battlers[current_turn_idx]
	
	_update_turn()
	
	
func _update_turn() -> void:
	current_turn.set_active()
	
	var type = current_turn.entity.type
	var isPlayer = type == BaseEntity.Type.PLAYER
	ally_turn = isPlayer or type == BaseEntity.Type.ALLY
	
	if ally_turn:
		change_active_menu(main_box)
	
	menu_box.visible = ally_turn
	select_icon.visible = false

	item_btn.visible = isPlayer
	neg_btn.visible = isPlayer
	
	current_turn.entity.regen_mp()
		
	skill_menu.hide()
	item_menu.hide()
	target_menu.hide()
		
	current_turn.start_turn()
	
	
func clear_menu(container: GridContainer) -> void:
	for n in container.get_children():
		container.remove_child(n)


func process_enemy_death(enemy):
	if game_over:
		return
	enemy_battlers.erase(enemy)
	battlers.erase(enemy)
	remove_child(enemy)
	
	if(enemy_battlers.size() == 0):
		game_over = true
		get_tree().paused = true
		victory_screen.show()
		return
		
	_choose_target(enemy_battlers[0])
	
	
func process_ally_death(ally):
	if game_over:
		return	
	if(ally.entity.type == BaseEntity.Type.PLAYER):
		get_tree().paused = true
		game_over = true
		
		defeat_screen.show()
		return
	
	battlers.erase(ally)
	ally_battlers.erase(ally)
	
	ally.sprite.self_modulate = Color.BLACK
	
	Global.team.erase(ally.entity)


func adjust_select_icon(button: Button) -> void:
	select_icon.show()
	select_icon.global_position = button.global_position

	select_icon.position.y += (select_icon.size.y * select_icon.scale.y) / 8
	select_icon	.position.x -= (select_icon.size.x * select_icon.scale.x) / 4


func get_player_target() -> Node2D:
	clear_menu(target_container)
	
	for character in ally_battlers:
		var target_button = target_button.instantiate() as TargetButton
		target_button.initialize(self, character.entity.name)
		target_button.pressed.connect(Callable(self, "_chosen_player").bind(character))
		target_button.mouse_entered.connect(Callable(self, "adjust_select_icon").bind(target_button))
		
		target_container.add_child(target_button)
	
	skill_menu.hide()
	target_menu.show()
	select_icon.visible = false
	change_active_menu(target_container)
	
	info_text.text = "Choose a player character"
	
	var target = await target_chosen
	
	info_text.text = "Choose your next action"
	
	return target


func _chosen_player(character: Node2D) -> void:
	target_chosen.emit(character)


func _on_continue_game_pressed() -> void:
	Global._show_map()


func _on_quit_game_pressed() -> void:
	Global.game_over()


func _on_new_run_pressed() -> void:
	Global.start_new_run()


func _input(event: InputEvent) -> void:
	if game_over:
		return
	
	if event.is_action_pressed("Back"):
		exit_sub_menu()
		return
	
	if event.is_action_pressed("Confirm"):
		active_btn.pressed.emit()	
		return	
				
	
	if ally_turn:		
		var enemy_index = enemy_battlers.find(selected_target)
		
		if event.is_action_pressed("ShoulderLeft"):
			enemy_index = (enemy_index + 1) % len(enemy_battlers)
			_choose_target(enemy_battlers[enemy_index])
			return
			
		if event.is_action_pressed("ShoulderRight"):
			enemy_index = (enemy_index - 1) % len(enemy_battlers)
			_choose_target(enemy_battlers[enemy_index])
			return
				
	var new_index = btn_index
				
	if event.is_action_pressed("Down"):
		new_index.x = btn_index.x + 1
	if event.is_action_pressed("Up"):
		new_index.x = max(0, btn_index.x - 1)
	if event.is_action_pressed("Left"):
		new_index.y = max(0, btn_index.y - 1)
	if event.is_action_pressed("Right"):
		new_index.y = btn_index.y + 1

	if new_index in btn_dict and new_index != btn_index:
		btn_index = new_index
			
		active_btn = btn_dict[btn_index]
		call_deferred("_activate_button")


func exit_sub_menu() -> void:
	if target_menu.visible:
		target_menu.hide()
	elif skill_menu.visible:
		skill_menu.hide()
	elif item_menu.visible:
		item_menu.hide()
	return


func change_active_menu(button_box: GridContainer):
	btn_index = Vector2.ZERO
	var children = button_box.get_children()

	btn_dict = {}
	
	var index = ''
	var current_row = 0
	var current_col = 0
	for btn in children:
		if btn.visible == false or is_instance_valid(btn) == false:
			continue
		
		index = Vector2(current_row, current_col)
		btn_dict[index] = btn
		current_col += 1
		if current_col == button_box.columns:
			current_col = 0
			current_row += 1

	if btn_dict[Vector2.ZERO]:
		active_btn = btn_dict[Vector2.ZERO]
		call_deferred("_activate_button")


func _activate_button():
	if active_btn:
		active_btn._set_active()
