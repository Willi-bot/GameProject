extends Camera2D

var drag_active: bool = false
var last_mouse_pos: Vector2
var texture_rect: TextureRect

func _ready():
	texture_rect = get_parent().get_node("TextureRect")
	
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				drag_active = true
				last_mouse_pos = event.position
			else:
				drag_active = false
	elif event is InputEventMouseMotion and drag_active:
		var mouse_delta = last_mouse_pos - event.position
		last_mouse_pos = event.position
		
		if texture_rect:
			var rect_position = texture_rect.position
			var rect_size = texture_rect.size
			var screen_size = get_viewport().get_visible_rect().size
			
			var new_position = position + mouse_delta
			new_position.x = clamp(new_position.x, rect_position.x, rect_position.x + rect_size.x - screen_size.x)
			new_position.y = clamp(new_position.y, rect_position.y, rect_position.y + rect_size.y - screen_size.y)
			
			position = new_position
