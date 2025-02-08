extends Stage


@onready var prompt_box: TextScroll = $"Textbox/TextScroll"
@onready var answers_container = $"Textbox/Answers"

var prompt: String
var answers: Dictionary

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	prompt = "Do you really want me?
	Im just a small creature...
	Would i be of any use?"
	
	answers = {"Yes": 0.25, "No": -0.25}
	
	prompt_box.reveal_text(prompt)
	
	await prompt_box.text_completed
	
	for key in answers:
		answers_container.add_child(_add_response_button(key, _send_response, answers[key]))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
