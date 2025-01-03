extends Control

@onready var mapTexture: TextureRect = $TextureRect

var events = {}
var event_scene = preload("res://scenes/overworld/Event.tscn")

var map_root_position = Vector2(0, 0)

var scale_factor = 80
var map_scale = 65
var scale_diff = scale_factor - map_scale

const plane_height = 25 # Scaled up by 80: 2000 / by 65: 1625
const plane_width = 16 # Scaled up by 80: 1280 / by 65:  1040
const node_count = plane_height * plane_width / 9
const path_count = 6

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	var generator = preload("res://scenes/overworld/MapGenerator.gd").new()
	var map_data = generator.generate(plane_width, plane_height, node_count, path_count)
	var nodes = map_data[0]
	var paths = map_data[1]
	
	map_root_position = mapTexture.position
	
	map_root_position.x += (scale_diff * plane_width / 2)
	map_root_position.y += (scale_diff * plane_height / 2)
	
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
