extends CanvasLayer

@onready var pauseMenu: Control = $PauseMenu
# Called when the node enters the scene tree for the first time.

func changeState():
	if get_tree().paused:
		resume()
		return
	pause()	

func resume():
	print("Resuming the game")
	get_tree().paused = false
	pauseMenu.resume()

func pause():
	print("Pausing the game")
	get_tree().paused = true
	pauseMenu.pause()

func _process(delta: float):
	if Input.is_action_just_pressed("Escape") and get_tree().current_scene.name != "Overworld" and get_tree().current_scene.name != "MainMenu":
		changeState()
