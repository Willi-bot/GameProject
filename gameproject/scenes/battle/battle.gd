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

@onready var victory_screen: VictoryScreen = $VictoryScreen
@onready var defeat_screen: CanvasLayer = $DefeatScreen

var em: EntityManager = preload("res://managers/entity_manager.gd").new()
var vm: VictoryManager = preload("res://managers/victory_manager.gd").new()
var nm: NegotiationManager = preload("res://managers/negotiation_manager.gd").new()
var im: InputManager = preload("res://managers/input_manager.gd").new()

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

signal target_chosen(index: int)


func _ready() -> void:
	game_over = false
	
	# Spawn entities
	player_battlers = em.spawn_team(Vector2(237, 215), 120, self)
	enemy_battlers = em.spawn_enemies(Vector2(408, 110), -120, self)
	battlers = em.get_action_order(player_battlers, enemy_battlers)

	_connect_callbacks()
	_create_main_buttons()

	im.init(main_box, item_box, skill_box, target_box)
	im.change_active_menu(main_box)

	# Start battle
	current_turn = battlers[0]
	_update_turn()
	_choose_target(enemy_battlers[0])


func _connect_callbacks():
	for player in player_battlers:
		player.entity.turn_ended.connect(_next_turn)
		player.entity.death.connect(process_ally_death.bind(player))
		
	for enemy in enemy_battlers:
		enemy.entity.turn_ended.connect(_next_turn)
		enemy.deal_damage.connect(_attack_random_ally)
		enemy.target_enemy.connect(_choose_target)
		enemy.entity.death.connect(process_enemy_death.bind(enemy))


func get_button(name: String) -> Button:
	return main_box.get_node(name)


func _attack_enemy() -> void:
	if game_over:
		return
		
	current_turn.entity.start_attacking(selected_target)
		
		
func _choose_skill() -> void:
	if game_over:
		return
		
	select_icon.hide()
	
	clear_menu(skill_grid)
	
	for skill in current_turn.entity.skills:
		skill_grid.add_child(_create_asset_button(skill))

	im.change_active_menu(skill_box)
	
	
func _choose_item() -> void:
	select_icon.visible = false
	
	clear_menu(item_grid)
	
	for item in Global.inventory:
		item_grid.add_child(_create_asset_button(item))

	im.change_active_menu(item_box)


func _create_main_buttons():
	var container = main_box.get_node("Buttons")
	
	var attack_btn = main_button.instantiate() as MainButton
	attack_btn.initialize("Attack", "Attack an enemy")	
	attack_btn.pressed.connect(_attack_enemy)
	
	var skill_btn = main_button.instantiate()
	skill_btn.initialize("Skills", "Choose a skill")	
	skill_btn.pressed.connect(_choose_skill)
	
	item_btn = main_button.instantiate()
	item_btn.initialize("Item", "Choose an item")	
	item_btn.pressed.connect(_choose_item)
	
	neg_btn = main_button.instantiate() as MainButton
	neg_btn.initialize("Negotiate", "Negotiate with enemy")	
	neg_btn.pressed.connect(_choose_neg_target)

	for c in [attack_btn, skill_btn, item_btn, neg_btn]:
		container.add_child(c)


func _create_asset_button(asset: Asset) -> Button:
	var btn = asset_button.instantiate() as AssetButton
	btn.initialize(asset)
	
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
	
	if ally_turn:
		im.change_active_menu(main_box)
	
	menu_box.visible = ally_turn
	select_icon.visible = false

	item_btn.visible = isPlayer
	neg_btn.visible = isPlayer
		
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
		vm.calculate_experience(slain_enemies)
		victory_screen.show_results(vm.earned_exp)
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
	
	
	Global.team.erase(ally.entity)


func get_player_target() -> Node2D:
	clear_menu(target_grid)
	
	for character in player_battlers:
		var target_button = target_button.instantiate() as TargetButton
		target_button.initialize(character.entity.name)
		target_button.pressed.connect(Callable(self, "_chosen_player").bind(character))
		
		target_grid.add_child(target_button)
	
	select_icon.visible = false
	im.change_active_menu(target_box)
	
	info_text.text = "Choose a player character"
	
	var target = await target_chosen
	
	info_text.text = "Choose your next action"
	
	return target


func _chosen_player(character: Node2D) -> void:
	target_chosen.emit(character)


func _on_continue_game_pressed() -> void:
	vm.distribute_exp(player_battlers)
	
	Global._show_map()


func _on_quit_game_pressed() -> void:
	Global.game_over()


func _on_new_run_pressed() -> void:
	Global.start_new_run()


func _input(event: InputEvent) -> void:
	if game_over or Global.paused:
		return
	
	if ally_turn and event.is_action_pressed("EnemySelection"):		
		_choose_target(enemy_battlers[im.select_enemy(event, selected_target, enemy_battlers)])		
		return
				
	im.select_action(event)


func _choose_neg_target() -> void:
	select_icon.hide()
	im.change_active_menu(null)
	nm.prepare_negotiation()
	
	info_text.text = "Confirm negotiation partner"
