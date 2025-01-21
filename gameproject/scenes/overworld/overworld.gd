class_name Overworld
extends Node2D

@onready var map_texture: TextureRect = $TextureRect
@onready var camera: Camera2D = $Camera2D
@onready var top_menu: MenuBar = $TopMenu/TopMenu
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

signal map_exited(type: Room.Type)

func reset():
	for child in lines.get_children():
		lines.remove_child(child)
	
	for child in rooms.get_children():
		rooms.remove_child(child)


func generate_new_map() -> void:
	reset()
	camera.position = Vector2.ZERO
	floors_climbed = 0
	map_data = map_generator.generate_map()
	create_map()
	unlock_floor(0)


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
	visuals.position.y = map_texture.position.y / 2 + 650


func unlock_floor(which_floor: int = floors_climbed) -> void:
	for map_room: MapRoom in rooms.get_children():
		if map_room.room.row == which_floor:
			map_room.available = true


func unlock_next_rooms() -> void:
	for map_room: MapRoom in rooms.get_children():
		for next in last_room.next_rooms:
			if next.position == map_room.room.position:
				map_room.available = true			


func show_map() -> void:
	show()
	top_menu.show()
	top_menu.update()
	top_menu.set_process(true)
	camera.enabled = true


func hide_map() -> void:
	hide()
	top_menu.hide()
	top_menu.set_process(false)
	camera.enabled = false			


func _spawn_room(room: Room) -> void:
	var new_map_room := MAP_ROOM.instantiate() as MapRoom
	rooms.add_child(new_map_room)
	new_map_room.room = room
	new_map_room.selected.connect(_on_map_room_selected)
	new_map_room.available = room.available
	_connect_lines(room)
	
	if room.selected:
		new_map_room.mark_selected()
	
	if room.row < floors_climbed:
		new_map_room.mark_inactive()


func _connect_lines(room: Room) -> void:
	if room.next_rooms.is_empty():
		return
	
	for next: Room in room.next_rooms:
		var new_map_line := MAP_LINE.instantiate() as Line2D
		new_map_line.add_point(room.position)
		new_map_line.add_point(next.position)
		lines.add_child(new_map_line)	


func _on_map_room_selected(room: Room):
	for map_room: MapRoom in rooms.get_children():
		if map_room.room.row == room.row:
			map_room.available = false
			map_room.mark_inactive()
 	
	last_room = room
	floors_climbed += 1

	map_exited.emit(room.type)


func serialize() -> Dictionary:
	var serialized_map = []
	for floor in map_data:
		var serialized_floor = []
		for room: Room in floor:
			serialized_floor.append(room.serialize())
		serialized_map.append(serialized_floor)
	
	return {
		"map_data": serialized_map,
		"floors_climbed": floors_climbed,
		"last_room": last_room.serialize() if last_room else null
	}


func deserialize(data: Dictionary) -> void:
	floors_climbed = data.get("floors_climbed", 0)
	last_room = null
	if data["last_room"]:		
		last_room = Room.new()
		last_room.deserialize(data["last_room"])
	
	map_data = []
	for floor_data in data.get("map_data", []):
		var floor = []
		for room_data in floor_data:
			var room = Room.new()
			room.deserialize(room_data)
			floor.append(room)
		map_data.append(floor)
	
	reset()
	create_map()
