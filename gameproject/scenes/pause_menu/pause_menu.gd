extends Control

@onready var resumeBtn : Button = $PanelContainer/VBoxContainer/Resume
@onready var restartBtn : Button = $PanelContainer/VBoxContainer/Restart
@onready var quitBtn : Button = $PanelContainer/VBoxContainer/Quit


func _ready():
	changeBtnStates(true)
	$AnimationPlayer.play("RESET")

func changeBtnStates(disabled):
	resumeBtn.disabled = disabled
	restartBtn.disabled = disabled
	quitBtn.disabled = disabled

func resume():
	get_tree().paused = false
	changeBtnStates(true)
	
	$AnimationPlayer.play_backwards("blur")
	
func pause():
	get_tree().paused = true	
	changeBtnStates(false)

	$AnimationPlayer.play("blur")

func testEsc():
	if Input.is_action_just_pressed("Escape") and get_tree().paused == false:
		pause()
	elif Input.is_action_just_pressed("Escape") and get_tree().paused == true:
		resume() 		

func _on_resume_pressed() -> void:
	resume()


func _on_restart_pressed() -> void:
	resume()
	get_tree().reload_current_scene()


func _on_quit_pressed() -> void:
	get_tree().quit()
	
func _process(delta: float):
	testEsc()	
