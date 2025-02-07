extends Stage


@onready var prompt_box = $"Textbox/Prompt"
@onready var answers_container = $"Textbox/Answers"

var prompt: String
var answers: Dictionary

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	prompt = "Do you love me?"
	answers = {"Yes": 0.25, "No": -0.25}
	
	prompt_box.text = prompt
	
	for key in answers:
		var answer_button: Button = Button.new()
		answer_button.text = key
		answer_button.pressed.connect(_send_response.bind(answers[key]))
		answers_container.add_child(answer_button)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
