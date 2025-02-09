extends Stage
class_name DemandGold


@onready var prompt_box: TextScroll = $"Textbox/TextScroll"
@onready var answers_container = $"Textbox/Answers"

var prompt: String
var demand: int

func _ready() -> void:
	# complicated formula to calculate the amount
	demand = 150
	
	prompt = "Can I have some of your gold?
	Pretty pretty please?
	How about %s gold?" % str(demand)
	
	prompt_box.reveal_text(prompt)
	
	await prompt_box.text_completed
	
	answers_container.add_child(_add_response_button("Here you go", _spend_gold, 0))
	answers_container.add_child(_add_response_button("No way", _send_response, 0, -0.25))

func _spend_gold() -> void:
	# spend gold TODO
	_send_response(0.25)
