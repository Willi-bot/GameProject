extends Node2D

@onready var mapTexture: TextureRect = $TextureRect
@onready var camera: Camera2D = $Camera2D
@onready var topMenu: CanvasLayer = $TopMenu
@onready var menus: CanvasLayer = $MenuLayer

const MAP_ROOM = preload("res://scenes/overworld/map_room.tscn")
const MAP_LINE = preload("res://scenes/overworld/map_line.tscn")

@onready var map_generator: MapGenerator = $MapGenerator
@onready var lines: Node2D = $Visuals/Lines
@onready var rooms: Node2D = $Visuals/Rooms
@onready var visuals: Node2D = $Visuals

var map_data: Array[Array]
var floors_climbed: int
var last_room: Room


func _ready() -> void:
	generate_new_map()
	unlock_floor(0)

func generate_new_map() -> void:
	floors_climbed = 0
	map_data = map_generator.generate_map()
	create_map()


func create_map():			
	for current_floor: Array in map_data:
		for room: Room in current_floor:
			if room.next_rooms.size() > 0:
				_spawn_room(room)
	
	var middle := floori(MapGenerator.MAP_WIDTH * 0.5)
	_spawn_room(map_data[MapGenerator.FLOORS - 1][middle])

	var map_width_pixels := MapGenerator.X_DIST * (MapGenerator.MAP_WIDTH - 1)
	var map_height_pixels := MapGenerator.Y_DIST * (MapGenerator.FLOORS - 1)

	visuals.position.x = (get_viewport_rect().size.x - map_width_pixels) / 2
	visuals.position.y = mapTexture.position.y / 2 + 650


func unlock_floor(which_floor: int = floors_climbed) -> void:
	for map_room: MapRoom in rooms.get_children():
		if map_room.room.row == which_floor:
			map_room.available = true


func unlock_next_rooms() -> void:
	for map_room: MapRoom in rooms.get_children():
		if last_room.next_rooms.has(map_room.room):
			map_room.available = true			


func show_map() -> void:
	show()
	camera.enabled = true


func hide_map() -> void:
	hide()
	camera.enabled = false			
			

func _spawn_room(room: Room) -> void:
	var new_map_room := MAP_ROOM.instantiate() as MapRoom
	rooms.add_child(new_map_room)
	new_map_room.room = room
	new_map_room.selected.connect(_on_map_room_selected)
	_connect_lines(room)
	
	if room.selected and room.row < floors_climbed:
		new_map_room.show_selected()
			

func _connect_lines(room: Room) -> void:
	if room.next_rooms.is_empty():
		return
	
	for next: Room in room.next_rooms:
		var new_map_line := MAP_LINE.instantiate() as Line2D
		new_map_line.add_point(room.position)
		new_map_line.add_point(next.position)
		lines.add_child(new_map_line)	

			
func _on_map_room_selected(room: Room):
	print("This event got emmited")
	
	for map_room: MapRoom in rooms.get_children():
		if map_room.room.row == room.row:
			map_room.available = false
 	
	last_room = room
	floors_climbed += 1

	
	var file = "res://scenes/battle/battle.tscn" if room.type == Room.Type.MONSTER else "res://scenes/recovery/recovery.tscn"
	
	
	# TODO MAKE MAP PERSISTENT
	unlock_next_rooms()
	
	get_tree().change_scene_to_file(file)
	
