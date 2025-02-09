extends Control
class_name Stage


signal response(value: float)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _send_response(response_value: float) -> void:
	response.emit(response_value)
	
	
func _add_response_button(text, function, width=0, value=null) -> Button:
	var response_button = ResponseButton.new()
	response_button.set_width(width)
	response_button.text = text
	if value == null:
		response_button.pressed.connect(function.bind())
	else:
		response_button.pressed.connect(function.bind(value))
	return response_button
