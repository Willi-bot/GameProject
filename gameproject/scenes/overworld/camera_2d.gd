extends Camera2D

var pan_speed: float = 200.0
var edge_threshold: int = 50

func _process(delta: float):
	var mouse_pos = get_viewport().get_mouse_position()
	var screen_size = get_viewport().get_visible_rect().size

	var move_y = 0.0
	if mouse_pos.y <= edge_threshold:
		move_y = -pan_speed * delta
	elif mouse_pos.y >= screen_size.y - edge_threshold:
		move_y = pan_speed * delta

	var texture_rect = get_parent().get_node("TextureRect")
	if texture_rect:
		var rect_position = texture_rect.position
		var rect_size = texture_rect.size

		var new_position = position + Vector2(0, move_y)
		new_position.y = clamp(new_position.y, rect_position.y, rect_position.y + rect_size.y - screen_size.y)
		position = new_position
