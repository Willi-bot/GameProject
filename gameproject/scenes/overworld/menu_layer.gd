extends CanvasLayer

@onready var pauseMenu: Control = $PauseMenu
@onready var teamMenu: Control = $TeamMenu
@onready var itemsMenu: Control = $ItemsMenu

var currentMenu: Control = null
var menus: Dictionary = {}

func _ready():
	menus = {
		"Pause": pauseMenu,
		"Team": teamMenu,
		"Items": itemsMenu
	}
	currentMenu = pauseMenu

func resume():
	get_tree().paused = false
	currentMenu.resume()
	visible = false

func pause():
	get_tree().paused = true
	currentMenu.pause()
	visible = true

func switch_menu(menu_key: String):
	var new_menu = menus[menu_key]
	if currentMenu != new_menu:
		currentMenu.resume()
		currentMenu = new_menu
		currentMenu._ready()
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
		
	if event.is_action("Items") and event.is_pressed():
		switch_menu("Items")
		return
		
func _on_items_pressed() -> void:
	switch_menu("Items")


func _on_team_pressed() -> void:
	switch_menu("Team")


func _on_settings_pressed() -> void:
	switch_menu("Pause")
