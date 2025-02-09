extends Label
class_name TextScroll

signal text_completed
signal line_completed

@export var characters_per_second: float = 20.0
@export var punctuation_delay: float = 0.2
@export var skip_delay_on_spaces: bool = true
@export var delay_between_lines: float = 0.5

var _lines: PackedStringArray = []
var _current_line_index: int = 0
var _original_text: String = ""
var _displayed_text: String = ""
var _char_index: int = 0
var _accumulated_time: float = 0.0
var _is_revealing: bool = false
var _line_delay_timer: float = 0.0
var _waiting_for_next_line: bool = false

func _ready():
	text = ""


# Call this with the text you want to display
func reveal_text(new_text: String) -> void:
	# Split the text into lines and store them
	_lines = new_text.split("\n")
	_current_line_index = 0
	start_next_line()


func start_next_line() -> void:
	if _current_line_index < _lines.size():
		_original_text = _lines[_current_line_index]
		_displayed_text = ""
		_char_index = 0
		_accumulated_time = 0.0
		_is_revealing = true
		_waiting_for_next_line = false
		text = ""
	else:
		text_completed.emit()


func _process(delta: float) -> void:
	if _waiting_for_next_line:
		_line_delay_timer -= delta
		if _line_delay_timer <= 0:
			_current_line_index += 1
			start_next_line()
		return
		
	if not _is_revealing:
		return
		
	_accumulated_time += delta
	
	var target_chars = floor(_accumulated_time * characters_per_second)
	
	while _char_index < _original_text.length() and _char_index < target_chars:
		var current_char = _original_text[_char_index]
		_displayed_text += current_char
		
		if current_char in ['.', '!', '?', ',']:
			_accumulated_time -= punctuation_delay
		elif current_char == " " and skip_delay_on_spaces:
			target_chars += 1
			
		_char_index += 1
		text = _displayed_text
	
	# Check if current line is complete
	if _char_index >= _original_text.length():
		_is_revealing = false
		line_completed.emit()
		
		# Start timer for next line
		if _current_line_index < _lines.size() - 1:
			_waiting_for_next_line = true
			_line_delay_timer = delay_between_lines
		else:
			text_completed.emit()


# This is called to skip the animation for the current line
func complete_current_line() -> void:
	if _is_revealing:
		_displayed_text = _original_text
		text = _displayed_text
		_is_revealing = false
		line_completed.emit()
		
		if _current_line_index < _lines.size() - 1:
			_waiting_for_next_line = true
			_line_delay_timer = delay_between_lines
		else:
			text_completed.emit()
