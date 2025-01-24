class_name ButtonBox
extends GridContainer

var btn_dict = {}
var current_index = Vector2.ZERO
var num_rows = 0

func init_button_dict():
	var children = get_children()
	num_rows = int(len(children) / columns)

	var index = ''
	var current_row = 0
	var current_col = 0
	for btn in children:
		index = Vector2(current_row, current_col)
		btn_dict[index] = btn
		current_col += 1
		if current_col == columns:
			current_col = 0
			current_row += 1


func adjust_position(position: String):
	var x = current_index.x
	var y = current_index.y
	
	if position == "Left":
		y = max(0, y - 1)
	if position == 'Right':
		y = min(columns - 1, y + 1)

	if position == "Up":
		x = max(0, x - 1)
	if position == "Down":
		x = min(num_rows - 1, x + 1)

		
	current_index = Vector2(x, y)
	var btn = btn_dict[current_index] as MainButton
	
	if btn.visible:
		btn._set_active()
