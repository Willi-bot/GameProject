extends Control

@onready var mapTexture: TextureRect = $TextureRect
@onready var camera: Camera2D = $Camera2D

var events = {}
var event_scene = preload("res://scenes/overworld/Event.tscn")

var textures = {
	"shop": preload("res://imgs/overworld_icons/coin.png"),
	"battle": preload("res://imgs/overworld_icons/battle_icon.png"),
	"suprise": preload("res://imgs/overworld_icons/question_mark_icon.png"),
	"recovery": preload("res://imgs/overworld_icons/heart_icon.png")
}

var texture_keys = textures.keys()

var map_root_position = Vector2(0, 0)

var scale_factor = 80
var map_scale = 65
var scale_diff = scale_factor - map_scale

const plane_height = 16 # Scaled up by 80: 2000 / by 65: 1625
const plane_width = 8 # Scaled up by 80: 1280 / by 65:  1040
const node_count = plane_height * plane_width / 9
const path_count = 6


func _ready() -> void:
	var generator = preload("res://scenes/overworld/MapGenerator.gd").new()
	var map_data = generator.generate(plane_width, plane_height, node_count, path_count)
	var nodes = map_data[0]
	var paths = map_data[1]
	
	map_root_position = mapTexture.position
	
	map_root_position.x += (scale_diff * plane_width / 2)
	map_root_position.y += (scale_diff * plane_height / 2)
	
	var current_node = 0
	
	for k in nodes.keys():
		var point = nodes[k]
		var event = event_scene.instantiate()
		
		var event_name = null
		
		if current_node % 2 == 1 or current_node == nodes.size() - 1:
			event_name = "battle"
		else:
			event_name = texture_keys[randi() % texture_keys.size()]
		
		event.set_event_type(event_name, textures[event_name])
		
		event.position = point * map_scale + map_root_position
		
		add_child(event)
		events[k] = event
		
		current_node += 1
	
	for path in paths:
		for i in range(path.size() - 1):
			var index1 = path[i]
			var index2 = path[i + 1]
			
			events[index1].add_child_event(events[index2])
