extends Camera2D

var pan_speed: float = 200.0  # Speed of panning in pixels per second
var edge_threshold: int = 50  # Distance from the screen edge to start panning


func _process(delta: float):
	# Get the mouse position and screen dimensions
	var mouse_pos = get_viewport().get_mouse_position()
	var screen_size = get_viewport().get_visible_rect().size

	# Calculate the vertical movement
	var move_y = 0.0
	if mouse_pos.y <= edge_threshold:
		move_y = -pan_speed * delta  # Pan up
	elif mouse_pos.y >= screen_size.y - edge_threshold:
		move_y = pan_speed * delta  # Pan down

	# Move the camera, clamping to the TextureRect bounds
	var texture_rect = get_parent().get_node("TextureRect")  # Adjust path as needed
	if texture_rect:
		var rect_position = texture_rect.position
		var rect_size = texture_rect.size

		# Get the camera's current position
		var new_position = position + Vector2(0, move_y)

		# Clamp the camera's y position to stay within the TextureRect bounds
		new_position.y = clamp(new_position.y, rect_position.y, rect_position.y + rect_size.y - screen_size.y)
		position = new_position
