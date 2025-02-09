extends Button
class_name ResponseButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func set_width(width: int) -> void:
	if width != 0:
		self.custom_minimum_size.x = width
