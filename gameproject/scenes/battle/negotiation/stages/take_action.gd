extends Stage


@onready var prompt_box = $"Textbox/Prompt"
@onready var answers_container = $"Textbox/Answers"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var prompt = "Do something?"
	
	prompt_box.reveal_text(prompt)
	
	await prompt_box.text_completed
	
	var width = 200
	var button: ResponseButton
	
	answers_container.add_child(_add_response_button("Convince", _convince, width))
	answers_container.add_child(_add_response_button("Intimidate", _intimidate, width))
	answers_container.add_child(_add_response_button("Show Compassion", _show_compassion, width))
	answers_container.add_child(_add_response_button("Do Nothing", _send_response, width, 0.))
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	
func _convince() -> void:
	var enemy_int: int = Global.bm.selected_target.entity.intelligence
	var player_int: int = Global.player.intelligence
	
	if player_int > enemy_int:
		_send_response(0.25)
	else:
		_send_response(-0.25)
	
func _intimidate() -> void:
	var enemy_str: int = Global.bm.selected_target.entity.strength
	var player_str: int = Global.player.strength
	
	if player_str > enemy_str:
		_send_response(0.25)
	else:
		_send_response(-0.25)
	
	
func _show_compassion() -> void:
	var rn = randf()
	
	if rn > 0.5:
		_send_response(0.25)
	else:
		_send_response(-0.25)
