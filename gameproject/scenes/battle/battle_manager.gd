extends Control

@onready var menu_box: HBoxContainer = $MenuBox
@onready var button_box: HBoxContainer = $MenuBox/ButtonBox
@onready var attack_button : Button = $MenuBox/ButtonPanel/ButtonBox/LeftSide/AttackButton
@onready var skill_button : Button = $MenuBox/ButtonPanel/ButtonBox/RightSide/SkillButton
@onready var item_button : Button = $MenuBox/ButtonPanel/ButtonBox/LeftSide/ItemButton
@onready var neg_button : Button = $MenuBox/ButtonPanel/ButtonBox/RightSide/NegButton

@onready var info_text : Label = $MenuBox/PanelContainer/InfoText

@onready var skill_menu : CanvasLayer = $MenuBox/ButtonPanel/ButtonBox/SkillMenu
@onready var skill_box : PanelContainer = $MenuBox/ButtonPanel/ButtonBox/SkillMenu/SkillBox

@onready var skill_resource : Resource = preload("res://scenes/entities/skill.gd")
@onready var skill_button_resource : Resource = preload("res://scenes/battle/skill_button.gd")
@onready var skill_button_entity = preload("res://scenes/battle/skill_button.tscn")

@onready var select_icon: TextureRect = $CanvasLayer/SelectIcon
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
	var char_pos = Vector2(480, 120)
	for enemy_character in enemy_data:
		var character = add_char_to_battle(enemy_character, BaseEntity.EntityType.ENEMY, char_pos)
		char_pos.x -= 120
		enemy_battlers.append(character)
	
	# load player data from globals or sth
	var player_data = get_player_data()
	char_pos = Vector2(75, 215)
	for player_character in player_data:
		var character = add_char_to_battle(player_character, BaseEntity.EntityType.PLAYER, char_pos)
		char_pos.x += 120
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
	var icon_scale = enemy_battlers[selected_target].scale
	target_icon.scale = enemy_battlers[selected_target].scale
	target_icon.position =  enemy_battlers[selected_target].position
	var y_offset = enemy_battlers[selected_target].get_node("CharacterSprite").texture_normal.get_height() / 2
	target_icon.position.y -= (2 * y_offset / 1.3) * icon_scale.y
	
	
	skill_box.size = $MenuBox.size
	skill_box.size.x = skill_box.size.x / 2.
	skill_box.position.y = $MenuBox.position.y
	skill_box.position.x = $MenuBox.position.x
	
	current_turn = all_battlers[current_turn_idx]
	_update_turn()
	
	select_icon.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func get_player_data() -> Array:
	var player_data: Array = []
	
	# load dummy data -> replace with some global shit
	player_data.append({"name": "Jeremiah", "max_hp": 200, "current_hp": 200, "max_mp": 5, "current_mp": 3, "damage": 60, 
						"agility": 4, "sprite": "res://imgs/player.png"})
	player_data.append({"name": "Baldwin", "max_hp": 350, "current_hp": 330, "max_mp": 2, "current_mp": 2, "damage": 30, 
						"agility": 1, "sprite": "res://imgs/player.png"})
	player_data.append({"name": "Denise", "max_hp": 150, "current_hp": 100, "max_mp": 3, "current_mp": 1, "damage": 100, 
						"agility": 2, "sprite": "res://imgs/player.png"})
	
	return player_data


func get_enemy_data() -> Array:
	var enemy_data: Array = []
	
	enemy_data.append({"name": "Gooner", "max_hp": 400, "current_hp": 400, "max_mp": 5, "current_mp": 3, "damage": 70, 
					   "agility": 3, "sprite": "res://imgs/enemy.png"})
	enemy_data.append({"name": "Gooner 2", "max_hp": 300, "current_hp": 300, "max_mp": 5, "current_mp": 3, "damage": 80, 
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
	instance.entity.max_mp = character["max_mp"]
	instance.entity.current_hp = character["current_hp"]
	instance.entity.current_mp = character["current_mp"]
	instance.entity.damage = character["damage"]
	instance.entity.agility = character["agility"]
	
	var sprite = instance.get_node("CharacterSprite")
	if type == BaseEntity.EntityType.PLAYER:
		sprite.texture = load(character["sprite"])
	else:
		sprite.texture_normal = load(character["sprite"])
	
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
		
		$MenuBox/ButtonPanel/ButtonBox/SkillMenu/SkillBox/SkillContainer.add_child(new_button)
		i += 1
		
	while i < 8:
		var invisible_button = Control.new()
		invisible_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		invisible_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		$MenuBox/ButtonPanel/ButtonBox/SkillMenu/SkillBox/SkillContainer.add_child(invisible_button)
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
		select_icon.show()
	else:
		attack_button.hide()
		select_icon.hide()
		
	# clear and hide skill menu
	for n in $MenuBox/ButtonPanel/ButtonBox/SkillMenu/SkillBox/SkillContainer.get_children():
		$MenuBox/ButtonPanel/ButtonBox/SkillMenu/SkillBox/SkillContainer.remove_child(n)
		n.queue_free() 
	skill_menu.visible = false
		
	current_turn.start_turn()


func has_battle_ended() -> bool:
	return false


func adjust_select_icon(button: Button) -> void:
	select_icon.visible = true
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
