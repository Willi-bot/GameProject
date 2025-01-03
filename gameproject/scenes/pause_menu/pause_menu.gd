extends Control


func _ready():
	self.visible = false
	$AnimationPlayer.play("RESET")

func resume():
	self.visible = false
	get_tree().paused = false

	
	$AnimationPlayer.play_backwards("blur")
	
func pause():
	self.visible = true
	get_tree().paused = true	


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
