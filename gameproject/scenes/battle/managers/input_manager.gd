extends Node
class_name InputManager

@export var item_box: PanelContainer
@export var target_box: PanelContainer
@export var skill_box: PanelContainer
@export var main_box: PanelContainer

var btn_dict = {}
var btn_index = Vector2.ZERO
var active_btn: BattleButton = null


func _init(main: PanelContainer, item: PanelContainer, skill: PanelContainer, target: PanelContainer):
	item_box = item
	target_box = target
	skill_box = skill
	main_box = main
	

func select_action(event: InputEvent) -> void:
	if event.is_action_pressed("Back"):
		change_active_menu(main_box)
		return
	
	if event.is_action_pressed("Confirm"):
		active_btn.pressed.emit()	
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


func select_enemy(event: InputEvent, selected_target: EnemyNode, enemy_battlers: Array[EnemyNode]):
	var enemy_index = enemy_battlers.find(selected_target)
		
	if event.is_action_pressed("ShoulderLeft"):
		enemy_index = (enemy_index + 1) % len(enemy_battlers)
		return enemy_index
		
	if event.is_action_pressed("ShoulderRight"):
		enemy_index = (enemy_index - 1) % len(enemy_battlers)
		return enemy_index

	return enemy_index
		
		
func change_active_menu(menu: PanelContainer):
	for menu_box in [item_box, target_box, skill_box, main_box]:
		menu_box.hide()
	
	if not menu:
		return
		
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
