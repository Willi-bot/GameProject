extends Panel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var screen_size = get_viewport_rect().size
	
	var newSizeX = screen_size.x * 0.8
	var newX = screen_size.x / 2
	
	var newSizeY = screen_size.y * 0.95
	var newY = 30
	
	self.custom_minimum_size.x = newSizeX
	self.custom_minimum_size.y = newSizeY
	
	self.position.x = newX
	self.position.y = newY


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
