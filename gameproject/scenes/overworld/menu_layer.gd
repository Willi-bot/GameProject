extends CanvasLayer

@onready var pauseMenu: Control = $PauseMenu
@onready var teamMenu: Control = $TeamMenu
@onready var inventoryMenu: Control = $InventoryMenu

var currentMenu: Control = null
var menus: Dictionary = {}

func _ready():
	menus = {
		"Pause": pauseMenu,
		"Team": teamMenu,
		"Inventory": inventoryMenu
	}
	currentMenu = pauseMenu


func resume():
	get_tree().paused = false
	Global.paused = false
	currentMenu.resume()
	currentMenu.hide()
	visible = false


func pause():
	get_tree().paused = true
	Global.paused = true
	currentMenu.pause()
	currentMenu.show()
	visible = true
	currentMenu.show()


func switch_menu(menu_key: String):
	var new_menu = menus[menu_key]
	if currentMenu != new_menu:
		currentMenu.resume()
		currentMenu.hide()
		currentMenu = new_menu
	if get_tree().paused:
		resume()
	else:
		pause()


func _input(event: InputEvent) -> void:
	if event.is_action("Escape") and event.is_pressed():
		switch_menu("Pause")
		return
		
	if event.is_action("Team") and event.is_pressed():
		switch_menu("Team")
		return
		
	if event.is_action("Inventory") and event.is_pressed():
		switch_menu("Inventory")
		return
	
	if event.is_action("Map") and event.is_pressed() and Global.current_view:
		switch_to_overworld()
		return 


func switch_to_overworld():
	if Global.overworld.is_visible_in_tree():
		Global.overworld.hide_map()
		Global.current_view.show()
	else:
		Global.overworld.show_map()
		Global.overworld.top_menu.hide()
		Global.current_view.hide()
		
func _on_items_pressed() -> void:
	switch_menu("Inventory")


func _on_team_pressed() -> void:
	switch_menu("Team")


func _on_settings_pressed() -> void:
	switch_menu("Pause")
