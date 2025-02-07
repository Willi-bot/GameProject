extends Stage


@onready var prompt_box = $"Textbox/Prompt"
@onready var answers_container = $"Textbox/Answers"

var prompt: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	prompt = "Can I have some of your life?"
	
	prompt_box.text = prompt
	
	answers_container.add_child(_add_response_button("Yes", _sacrifice_life, 0.25))
	answers_container.add_child(_add_response_button("No", _send_response, -0.25))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	
func _sacrifice_life(percentage_amount) -> void:
	Global.player.be_damaged(int(percentage_amount * Global.player.max_hp))
	_send_response(0.25)
