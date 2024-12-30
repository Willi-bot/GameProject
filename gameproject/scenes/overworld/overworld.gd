extends Control

var events = {}
var event_scene: Event = preload("res://scenes/overworld/Event.tscn")

const map_scale = 20.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var generator = preload("res://scenes/overworld/MapGenerator.gd").new()
	var map_data = generator.generate(30, 200, 3)
	var nodes = map_data[0]
	var paths = map_data[1]
	
	for k in nodes.keys():
		var point = nodes[k]
		var event = event_scene.instantiate()
		event.position = point * map_scale + Vector2(200, 0)
		add_child(event)
		events[k] = event
	
	for path in paths:
		for i in range(path.size() - 1):
			var index1 = path[i]
			var index2 = path[i + 1]
			
			events[index1].add_child_event(events[index2])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
