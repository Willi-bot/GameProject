extends Control

@onready var attack_button : Button = $MenuBox/ButtonBox/LeftSide/AttackButton
@onready var skill_button : Button = $MenuBox/ButtonBox/RightSide/SkillButton
@onready var item_button : Button = $MenuBox/ButtonBox/LeftSide/ItemButton
@onready var neg_button : Button = $MenuBox/ButtonBox/RightSide/NegButton

@onready var info_text : Label = $MenuBox/PanelContainer/InfoText

var all_battlers = []
var player_battlers = []
var enemy_battlers = []

var current_turn : Node2D
var current_turn_idx : int
var selected_target : int = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_battlers = get_tree().get_nodes_in_group("PlayerEntity")
	enemy_battlers = get_tree().get_nodes_in_group("EnemyEntity")
	
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
		e.deal_damage.connect(_attack_random_battler)
		e.entity.turn_ended.connect(_next_turn)
		
	current_turn = all_battlers[current_turn_idx]
	_update_turn()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _perform_attack() -> void:
	var target = enemy_battlers[selected_target]
	current_turn.entity.start_attacking(target)
	
	
func _choose_skill() -> void:
	print("Choosing a skill")
	
	
	
func _choose_item() -> void:
	print("Choosing an item")
	
	
func _choose_neg_target() -> void:
	print("Choose a Negotiation Partner")
	
	
func _attack_random_battler() -> void:
	var target = player_battlers[randi_range(0, player_battlers.size() - 1)]
	current_turn.entity.start_attacking(target)
	
	
func _next_turn() -> void:
	if has_battle_ended():
		pass # implement end of battle
	
	print("Starting next turn player")
	current_turn_idx = (current_turn_idx + 1) % all_battlers.size()
	current_turn = all_battlers[current_turn_idx]
	_update_turn()
	
	
func _update_turn() -> void:
	if current_turn.entity.type == BaseEntity.EntityType.PLAYER:
		attack_button.show()
	else:
		attack_button.hide()
		
	for b in all_battlers:
		print(b.entity.type)
		print(b.entity.current_hp)
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
