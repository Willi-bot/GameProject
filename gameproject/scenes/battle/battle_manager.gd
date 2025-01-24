class_name BattleManager
extends Control

@onready var menu_box = $MenuBox
@onready var button_panel = $MenuBox/ButtonPanel
@onready var button_box = $MenuBox/ButtonPanel/ButtonBox

@onready var attack_button = get_button("LeftSide/AttackButton")
@onready var skill_button = get_button("RightSide/SkillButton")
@onready var item_button = get_button("LeftSide/ItemButton")
@onready var neg_button = get_button("RightSide/NegButton")

@onready var info_text : Label = $MenuBox/PanelContainer/InfoText

@onready var skill_menu : CanvasLayer = button_box.get_node("SkillMenu")
@onready var skill_box : PanelContainer = button_box.get_node("SkillMenu/SkillBox")
@onready var skill_container : GridContainer =  button_box.get_node("SkillMenu/SkillBox/SkillContainer")
@onready var item_menu : CanvasLayer = button_box.get_node("ItemMenu")
@onready var item_box : PanelContainer = button_box.get_node("ItemMenu/ItemBox")
@onready var item_container : GridContainer =  button_box.get_node("ItemMenu/ItemBox/ItemContainer")
@onready var target_menu : CanvasLayer = button_box.get_node("PlayerTargetMenu")
@onready var target_menu_box : PanelContainer = button_box.get_node("PlayerTargetMenu/TargetBox")
@onready var target_container : HBoxContainer = button_box.get_node("PlayerTargetMenu/TargetBox/TargetContainer")

@onready var skill_resource : Resource = preload("res://assets/skill.gd")
@onready var item_resource : Resource = preload("res://assets/item.gd")
@onready var asset_button: PackedScene = preload("res://scenes/battle/buttons/asset_button.tscn")
@onready var target_button: PackedScene = preload("res://scenes/battle/buttons/target_button.tscn")
@onready var select_icon: TextureRect = $SelectLayer/SelectIcon

@onready var victory_screen: CanvasLayer = $VictoryScreen
@onready var defeat_screen: CanvasLayer = $DefeatScreen

var enemy_scene = preload("res://entities/enemy/enemy.tscn")

var battlers = []
var ally_battlers = []
var enemy_battlers = []

var current_turn : Node2D
var current_turn_idx : int
var selected_target : Node2D 

var game_over: bool

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

	_setup_boxes([skill_box, item_box, target_menu_box])

	current_turn = battlers[current_turn_idx]
	_update_turn()
	
	_choose_target(enemy_battlers[0])


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
	attack_button.pressed.connect(_attack_enemy)
	skill_button.pressed.connect(_choose_skill)
	item_button.pressed.connect(_choose_item)
	neg_button.pressed.connect(_choose_neg_target)

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
	return button_box.get_node(name)


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
	current_turn.entity.start_attacking(selected_target)
		
		
func _choose_skill() -> void:
	select_icon.visible = false
	
	clear_menu(skill_container)
	
	for skill in current_turn.entity.skills:
		skill_container.add_child(_create_asset_button(skill))

	skill_menu.show()
	
	
func _choose_item() -> void:
	select_icon.visible = false
	
	clear_menu(item_container)
	
	for item in Global.inventory:
		item_container.add_child(_create_asset_button(item))

	item_menu.show()
	
	
func _create_asset_button(asset: Asset) -> Button:
	var btn = asset_button.instantiate() as AssetButton
	btn.initialize(asset, self)
	
	btn.pressed.connect(Callable(btn, "_on_button_pressed").bind(current_turn.entity))
	btn.mouse_entered.connect(Callable(btn, "_on_mouse_entered").bind(select_icon, info_text))
	btn.mouse_exited.connect(Callable(btn, "_on_mouse_exited").bind(info_text))
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
	var isAlly = isPlayer or type == BaseEntity.Type.ALLY
	
	menu_box.visible = isAlly
	select_icon.visible = false

	item_button.visible = isPlayer
	neg_button.visible = isPlayer
	
	current_turn.entity.regen_mp()
		
	skill_menu.hide()
	item_menu.hide()
	target_menu.hide()
		
	current_turn.start_turn()
	
	
func clear_menu(container) -> void:
	for n in container.get_children():
		n.queue_free()


func process_enemy_death(enemy):
	enemy_battlers.erase(enemy)
	battlers.erase(enemy)
	remove_child(enemy)
	
	if(enemy_battlers.size() == 0):
		game_over = true
		victory_screen.show()
		get_tree().paused = true
		
		return
		
	_choose_target(enemy_battlers[0])
	
	
func process_ally_death(ally):	
	if(ally.entity.type == BaseEntity.Type.PLAYER):
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
	info_text.text = "Start Negotiation with a Creature"
	adjust_select_icon(neg_button)


func _on_neg_button_mouse_exited() -> void:
	info_text.text = "Choose your next action"


func get_player_target() -> Node2D:
	clear_menu(target_container)
	
	for character in ally_battlers:
		var target_button = target_button.instantiate()
		target_button.text = character.entity.name
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
	Global._show_map()


func _on_quit_game_pressed() -> void:
	Global.game_over()


func _on_new_run_pressed() -> void:
	Global.start_new_run()


func _input(event: InputEvent) -> void:
	if event.is_action("Back") and event.is_pressed():
		exit_sub_menu()
		return


func exit_sub_menu() -> void:
	if target_menu.visible:
		target_menu.hide()
	elif skill_menu.visible:
		skill_menu.hide()
	elif item_menu.visible:
		item_menu.hide()
	
	return
