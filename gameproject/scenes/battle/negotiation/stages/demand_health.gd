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
	
	var answer_button: Button = Button.new()
	answer_button.text = "Yes"
	answer_button.pressed.connect(_sacrifice_life.bind(0.25))
	answers_container.add_child(answer_button)
	
	answer_button = Button.new()
	answer_button.text = "No"
	answer_button.pressed.connect(_send_response.bind(-0.25))
	answers_container.add_child(answer_button)

func _sacrifice_life(percentage_amount) -> void:
	Global.player.be_damaged(int(percentage_amount * Global.player.max_hp))
	_send_response(0.25)
