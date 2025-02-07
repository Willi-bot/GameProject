extends Stage


@onready var prompt_box = $"Textbox/Prompt"
@onready var answers_container = $"Textbox/Answers"

var prompt: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	prompt = "Can I have some of your life?"
	
	prompt_box.text = prompt
	
	var answer_button: Button = Button.new()
	answer_button.text = "Yes"
	answer_button.pressed.connect(_sacrifice_life.bind(0.25))
	answers_container.add_child(answer_button)
	
	answer_button = Button.new()
	answer_button.text = "No"
	answer_button.pressed.connect(_send_response.bind(-0.25))
	answers_container.add_child(answer_button)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	
func _sacrifice_life(percentage_amount) -> void:
	Global.player.be_damaged(int(percentage_amount * Global.player.max_hp))
	_send_response(0.25)
