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

@onready var skill_resource : Resource = preload("res://scenes/entities/asset/skill.gd")
@onready var item_resource : Resource = preload("res://scenes/entities/asset/item.gd")
@onready var asset_button_entity = preload("res://scenes/battle/buttons/asset_button.tscn")
@onready var select_icon: TextureRect = $SelectLayer/SelectIcon

@onready var victory_screen: CanvasLayer = $VictoryScreen
@onready var defeat_screen: CanvasLayer = $DefeatScreen

var enemy_scene = preload("res://scenes/entities/enemy_entity.tscn")

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
	_spawn_enemies(enemy_data, Vector2(480, 120), -120)
	
	_add_allies(Vector2(75, 215), 120)

	battlers = ally_battlers + enemy_battlers
	battlers.sort_custom(func(a, b): return a.entity.agility > b.entity.agility)

	_connect_buttons()
	_connect_ally_callbacks(ally_battlers)
	_connect_enemy_callbacks(enemy_battlers)

	_setup_box(skill_box)
	_setup_box(item_box)
	_setup_box(target_menu_box)

	current_turn = battlers[current_turn_idx]
	_update_turn()
	
	_choose_target(enemy_battlers[0])


func _spawn_enemies(data, start_pos, offset_x):
	var index = 0
	var entity = null
	
	for entity_data in data:
		entity = _add_enemy_to_battle(entity_data, start_pos)
		enemy_battlers.append(entity)
		add_child(entity)
		start_pos.x += offset_x


func _add_allies(start_pos, offset_x):
	print("Adding allies to the battle", Global.player, Global.team)
	
	for ally in [Global.player] + Global.team as Array[PlayerEntity]:
		ally.position = start_pos
		add_child(ally)
		print(ally.sprite, ally.back_sprite, start_pos, ally.entity)
		ally.back_sprite.visible = true
		ally.sprite.visible = false
		ally_battlers.append(ally)
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


func load_enemy_data() -> Array:
	var file = FileAccess.open("res://creatures/creatures_data.json", FileAccess.READ)
	var json = JSON.new()
	var result = json.parse(file.get_as_text())
	
	# TODO: Add logic for dynamically loading enemies based on level
	
	return json.get_data()


func _add_enemy_to_battle(data, pos) -> Node2D:	
	var instance = Global.ENEMY_SCENE.instantiate()	
	instance.entity = Global.BASE_ENTITY.new()
	
	var sprite = instance.get_node("Sprite")
	sprite.texture = load(data["sprite"])

	for key in data.keys():
		instance.entity.set(key, data[key])
			
	instance.position = pos
	
	return instance


func _attack_enemy() -> void:
	var target = selected_target
	current_turn.entity.start_attacking(target)
		
		
func _choose_skill() -> void:
	select_icon.visible = false
	
	var i = 0
	
	for skill in current_turn.entity.skills:
		var new_button = _create_asset_button("skill", skill)
		
		if current_turn.entity.current_mp < new_button.asset.mp_cost:
			new_button.disabled = true
		
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
	select_icon.visible = false
	
	var i = 0
	for item in Global.inventory.keys():
		var count = Global.inventory[item]
		var new_button = _create_asset_button("item", item)
		new_button.asset.count = count
		new_button.text += " (%sx)" % count
		new_button.asset.use_item.connect(_update_item_count.bind(item))
		
		item_container.add_child(new_button)
		i += 1
		
	while i < 8:
		var invisible_button = Control.new()
		invisible_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		invisible_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		skill_container.add_child(invisible_button)
		i += 1
	
	item_menu.visible = true
	
	
func _create_asset_button(asset_type, asset) -> Button:
	var new_button = asset_button_entity.instantiate()
	new_button.initialize(asset_type, asset, self)
	new_button.text = new_button.asset.asset_name
	new_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	new_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	new_button.pressed.connect(Callable(new_button, "_on_button_pressed").bind(current_turn))
	new_button.mouse_entered.connect(Callable(new_button, "_on_mouse_entered").bind(select_icon, info_text))
	new_button.mouse_exited.connect(Callable(new_button, "_on_mouse_exited").bind(info_text))
	new_button.asset.turn_ended.connect(_next_turn)
	
	return new_button
	
	
func _update_item_count(item) -> void:
	Global.inventory[item] -= 1
	if Global.inventory[item] == 0:
		Global.inventory.erase(item)
	
	
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
	var isPlayer = type == Entity.Type.PLAYER
	var isAlly = isPlayer or type == Entity.Type.ALLY
	
	menu_box.visible = isAlly
	select_icon.visible = false

	item_button.visible = isPlayer
	neg_button.visible = isPlayer
	
	current_turn.entity.regen_mp()
		
	clear_menu(skill_container)
	skill_menu.hide()
	
	clear_menu(item_container)
	item_menu.hide()
	
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
	battlers.erase(enemy)
	remove_child(enemy)
	
	if(enemy_battlers.size() == 0):
		game_over = true
		victory_screen.show()
		get_tree().paused = true
		
		return
		
	_choose_target(enemy_battlers[0])
	
	
func process_ally_death(ally):	
	if(ally.entity.type == Entity.Type.PLAYER):
		game_over = true
		defeat_screen.show()
		get_tree().paused = true
		
		return
	
	battlers.erase(ally)
	ally_battlers.erase(ally)
	
	ally.sprite.self_modulate = Color.BLACK

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


func restore_nodes():
	for ally in ally_battlers:
		remove_child(ally)


func _on_continue_game_pressed() -> void:
	restore_nodes()
	Global._show_map()


func _on_quit_game_pressed() -> void:
	restore_nodes()
	Global.game_over()


func _on_new_run_pressed() -> void:
	Global.start_new_run()
