extends Stage


@onready var prompt_box: TextScroll = $"Textbox/TextScroll"
@onready var answers_container = $"Textbox/Answers"

var prompt: String


func _ready() -> void:
	prompt = "Can I have some of your life?
	Pretty pretty please?
	I might join your team
	Or not..."
	
	prompt_box.reveal_text(prompt)
	
	await prompt_box.text_completed
	
	answers_container.add_child(_add_response_button("Yes", _sacrifice_life, 0.25))
	answers_container.add_child(_add_response_button("No", _send_response, -0.25))

func _sacrifice_life(percentage_amount) -> void:
	Global.player.be_damaged(int(percentage_amount * Global.player.max_hp))
	_send_response(0.25)
