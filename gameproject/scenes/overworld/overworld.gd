extends Control


var events = {}
var event_scene = preload("res://scenes/overworld/Event.tscn")

var map_root_position = Vector2(0, 0)
var map_scale = 30.0
var padding = 80

const plane_len = 15
const node_count = plane_len * plane_len / 9
const path_count = 6


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var generator = preload("res://scenes/overworld/MapGenerator.gd").new()
	var map_data = generator.generate(plane_len, node_count, path_count)
	var nodes = map_data[0]
	var paths = map_data[1]
	
	map_root_position = get_viewport_rect().size
	map_root_position.x = map_root_position.x / 2 - (plane_len / 2 * map_scale)
	map_root_position.y -= plane_len * map_scale + padding
	
	for k in nodes.keys():
		var point = nodes[k]
		var event = event_scene.instantiate()
		event.position = point * map_scale + map_root_position
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
