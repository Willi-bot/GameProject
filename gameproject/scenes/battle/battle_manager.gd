class_name BattleManager
extends Control

@onready var menu_box = $MenuBox
@onready var menu_container = $MenuBox/MenuContainer
@onready var main_box: PanelContainer = $MenuBox/MenuContainer/MainBox
@onready var main_grid: GridContainer = $MenuBox/MenuContainer/MainBox/Buttons
@onready var item_box: PanelContainer = $MenuBox/MenuContainer/ItemBox
@onready var item_grid: GridContainer = $MenuBox/MenuContainer/ItemBox/Buttons
@onready var skill_box: PanelContainer = $MenuBox/MenuContainer/SkillBox
@onready var skill_grid: GridContainer = $MenuBox/MenuContainer/SkillBox/Buttons
@onready var target_box: PanelContainer = $MenuBox/MenuContainer/TargetBox
@onready var target_grid: GridContainer = $MenuBox/MenuContainer/TargetBox/Buttons


@onready var info_text : Label = $MenuBox/DescriptionContainer/InfoText

@onready var skill_container : GridContainer = $MenuBox/ButtonPanel/SkillMenu/SkillBox/SkillContainer
@onready var item_container : GridContainer = $MenuBox/ButtonPanel/ItemMenu/ItemBox/ItemContainer
@onready var target_menu_box : PanelContainer = $MenuBox/ButtonPanel/PlayerTargetMenu/TargetBox
@onready var target_container : GridContainer = $MenuBox/ButtonPanel/PlayerTargetMenu/TargetBox/TargetContainer

@onready var skill_resource : Resource = preload("res://assets/skill.gd")
@onready var item_resource : Resource = preload("res://assets/item.gd")
@onready var main_button: PackedScene = preload("res://scenes/battle/buttons/main_button.tscn")
@onready var asset_button: PackedScene = preload("res://scenes/battle/buttons/asset_button.tscn")
@onready var target_button: PackedScene = preload("res://scenes/battle/buttons/target_button.tscn")
@onready var select_icon: Sprite2D = $SelectIcon
@onready var target_icon: AnimatedSprite2D = $TargetIcon

@onready var negotation_scene = preload("res://scenes/battle/negotiation/Negotiation.tscn")
@onready var negotiation: Negotiation = null

@onready var victory_screen: VictoryScreen = $VictoryScreen
@onready var defeat_screen: CanvasLayer = $DefeatScreen

var em: EntityManager = preload("res://scenes/battle/entity_manager.gd").new()
var vm: VictoryManager = preload("res://scenes/battle/victory_manager.gd").new()

var enemy_scene = preload("res://entities/enemy/enemy.tscn")

var item_btn = null
var neg_btn = null

var battlers = []
var player_battlers: Array[PlayerNode] = []
var enemy_battlers: Array[EnemyNode] = []
var slain_enemies: Array[EnemyEntity] = []

var current_turn : Node2D
var current_turn_idx : int

var selected_target : Node2D 
var ally_turn: bool = true
var game_over: bool = false

var initiate_negotiation: bool = false

# Used for keyboard selection
var btn_dict = {}
var btn_index = Vector2.ZERO
var active_btn: BattleButton = null

signal target_chosen(index: int)

func _ready() -> void:
	game_over = false
	
	player_battlers = em.spawn_team(Vector2(237, 215), 120, self)
	enemy_battlers = em.spawn_enemies(Vector2(408, 110), -120, self)

	battlers = em.get_action_order(player_battlers, enemy_battlers)

	_connect_callbacks()
	_create_main_buttons()

	call_deferred("_setup_boxes")

	current_turn = battlers[current_turn_idx]
	_update_turn()
	
	_choose_target(enemy_battlers[0])

	change_active_menu(main_box)


func _connect_callbacks():
	for player in player_battlers:
		player.entity.turn_ended.connect(_next_turn)
		player.entity.death.connect(process_ally_death.bind(player))
		
	for enemy in enemy_battlers:
		enemy.entity.turn_ended.connect(_next_turn)
		enemy.deal_damage.connect(_attack_random_ally)
		enemy.target_enemy.connect(_choose_target)
		enemy.target_enemy.connect(_start_negotiation)
		enemy.entity.death.connect(process_enemy_death.bind(enemy))


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


func _attack_enemy() -> void:
	if game_over:
		return
	current_turn.entity.start_attacking(selected_target)
		
		
func _choose_skill() -> void:
	if game_over:
		return
	select_icon.visible = false
	
	clear_menu(skill_grid)
	
	for skill in current_turn.entity.skills:
		skill_grid.add_child(_create_asset_button(skill))

	change_active_menu(skill_box)
	
	
func _choose_item() -> void:
	select_icon.visible = false
	
	clear_menu(item_grid)
	
	for item in Global.inventory:
		item_grid.add_child(_create_asset_button(item))

	change_active_menu(item_box)


func _create_main_buttons():
	var container = main_box.get_node("Buttons")
	
	var attack_btn = main_button.instantiate() as MainButton
	attack_btn.initialize(self, "Attack", "Attack an enemy")	
	container.add_child(attack_btn)
	attack_btn.pressed.connect(_attack_enemy)
	
	var skill_btn = main_button.instantiate() as MainButton
	skill_btn.initialize(self, "Skills", "Choose a skill")	
	container.add_child(skill_btn)
	skill_btn.pressed.connect(_choose_skill)
	
	item_btn = main_button.instantiate() as MainButton
	item_btn.initialize(self, "Item", "Choose an item")	
	container.add_child(item_btn)
	item_btn.pressed.connect(_choose_item)
	
	neg_btn = main_button.instantiate() as MainButton
	neg_btn.initialize(self, "Negotiate", "Negotiate with enemy")	
	container.add_child(neg_btn)
	neg_btn.pressed.connect(_choose_neg_target)


func _create_asset_button(asset: Asset) -> Button:
	var btn = asset_button.instantiate() as AssetButton
	btn.initialize(asset, self)
	
	btn.pressed.connect(Callable(btn, "_on_button_pressed").bind(current_turn.entity))
	btn.asset.turn_ended.connect(_next_turn)
	
	return btn
	
	
func _choose_target(target: EnemyNode) -> void:
	selected_target = target
	selected_target.set_target(target_icon)
	
	
func _attack_random_ally() -> void:
	if game_over or Global.paused:
		return
		
	await get_tree().create_timer(1).timeout 
	var ally = player_battlers[randi_range(0, player_battlers.size() - 1)]
	current_turn.entity.start_attacking(ally)
	
	
func _next_turn() -> void:
	if game_over or Global.paused:
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
	
	if is_instance_valid(negotiation):
		select_icon.show()
		for child in main_grid.get_children():
			child.show()
		
		remove_child(negotiation)
	
	if ally_turn:
		change_active_menu(main_box)
	
	menu_box.visible = ally_turn
	select_icon.visible = false

	item_btn.visible = isPlayer
	neg_btn.visible = isPlayer
	
	current_turn.entity.regen_mp()
		
	current_turn.start_turn()
	
	
func clear_menu(grid: GridContainer) -> void:
	for n in grid.get_children():
		grid.remove_child(n)


func process_enemy_death(enemy):
	if game_over or Global.paused:
		return
	
	slain_enemies.append(enemy.entity)	
	enemy_battlers.erase(enemy)
	battlers.erase(enemy)
	remove_child(enemy)
	
	if(enemy_battlers.size() == 0):
		game_over = true
		get_tree().paused = true
		var earned_exp = vm.calculate_experience(slain_enemies)
		victory_screen.show_results(earned_exp)
		return
		
	_choose_target(enemy_battlers[0])
	
	
func process_ally_death(ally):
	if game_over or Global.paused:
		return	
		
	if ally.entity.type == BaseEntity.Type.PLAYER:
		get_tree().paused = true
		game_over = true
		
		defeat_screen.show()
		return
	
	battlers.erase(ally)
	player_battlers.erase(ally)
	
	ally.sprite.self_modulate = Color.BLACK
	
	Global.team.erase(ally.entity)


func get_player_target() -> Node2D:
	clear_menu(target_grid)
	
	for character in player_battlers:
		var target_button = target_button.instantiate() as TargetButton
		target_button.initialize(self, character.entity.name)
		target_button.pressed.connect(Callable(self, "_chosen_player").bind(character))
		
		target_grid.add_child(target_button)
	
	select_icon.visible = false
	change_active_menu(target_box)
	
	info_text.text = "Choose a player character"
	
	var target = await target_chosen
	
	info_text.text = "Choose your next action"
	
	return target


func _chosen_player(character: Node2D) -> void:
	target_chosen.emit(character)


func _on_continue_game_pressed() -> void:
	var earned_exp = vm.calculate_experience(slain_enemies)
	vm.distribute_exp(player_battlers, earned_exp)
	
	Global._show_map()


func _on_quit_game_pressed() -> void:
	Global.game_over()


func _on_new_run_pressed() -> void:
	Global.start_new_run()


func _input(event: InputEvent) -> void:
	if game_over or Global.paused:
		return
	
	if event.is_action_pressed("Back"):
		change_active_menu(main_box)
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


func change_active_menu(menu: PanelContainer):
	for menu_box in [item_box, target_box, skill_box, main_box]:
		menu_box.hide()
	
	select_icon.hide()
	
	menu.show()
	
	btn_index = Vector2.ZERO
	var button_box = menu.get_node("Buttons") as GridContainer
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


func _choose_neg_target() -> void:
	# hide buttons in main box
	select_icon.hide()
	for child in main_grid.get_children():
		child.hide()
	
	info_text.text = "Confirm negotiation partner"
	
	initiate_negotiation = true
	
	# TODO make enemies light up corresponding to success chance
	
	
func _start_negotiation(enemy) -> void:
	# if initiate negotiation is true pass enemy to Negotiation scene and 
	# start negotiation
	if initiate_negotiation:
		# TODO calculate success chance based on enemy + level diff + damage dealt
		var success_chance: float = 0.5
		
		negotiation = negotation_scene.instantiate()
		
		negotiation.set_negotiation_partner(self, success_chance)
		
		negotiation.negotiation_end.connect(_process_end_of_negotiation)
		
		add_child(negotiation)


func _process_end_of_negotiation(success) -> void:
	if success:
		# Add enemy to party
		pass
	
	_next_turn()
