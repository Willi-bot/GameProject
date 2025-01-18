class_name Room
extends Resource

enum Type { NOT_ASSIGNED, MONSTER, SUPRISE, CAMPFIRE, SHOP, BOSS }

@export var type: Type
@export var row: int
@export var column: int
@export var position: Vector2
@export var next_rooms: Array[Room] = []
@export var selected := false
@export var available := false

func _to_string() -> String:
	return "%s (%s)" % [column, Type.keys()[type][0]]


# We only need the position for corretly placing the lines and uniquely identifying the room
func serialize_next_room(room: Room):
	return {
		"position": [room.position.x, room.position.y]
	}

func serialize() -> Dictionary:
	var serialized_next_rooms = []

	for room in next_rooms:
		serialized_next_rooms.append(serialize_next_room(room))

	return {
		"type": type,
		"grid_pos": [row, column],
		"position": [position.x, position.y],
		"next_rooms": serialized_next_rooms,
		"selected": selected,
		"available": available
	}


func deserialize(data: Dictionary) -> void:
	type = data.get("type", Type.NOT_ASSIGNED)
	
	var grid_pos = data.get("grid_pos", [0, 0])
	row = grid_pos[0]
	column = grid_pos[1]

	var mapPosition = data["position"]
	position = Vector2(mapPosition[0], mapPosition[1])
	selected = data.get("selected", false)
	available = data.get("available", false)

	for room_data in data.get("next_rooms", []):
		var room = Room.new()
		room.deserialize(room_data)
		next_rooms.append(room)
