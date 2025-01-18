class_name Room
extends Resource

enum Type { NOT_ASSIGNED, MONSTER, TREASURE, CAMPFIRE, SHOP, BOSS }

@export var type: Type
@export var row: int
@export var column: int
@export var position: Vector2
@export var next_rooms: Array[Room] = []
@export var selected := false
@export var available := false

func _to_string() -> String:
	return "%s (%s)" % [column, Type.keys()[type][0]]


func serialize() -> Dictionary:
	var serialized_next_rooms = []
	for room in next_rooms:
		serialized_next_rooms.append(room.serialize())
	
	return {
		"type": type,
		"row": row,
		"column": column,
		"position": [position.x, position.y],
		"next_rooms": serialized_next_rooms,
		"selected": selected,
		"available": available
	}


func deserialize(data: Dictionary) -> void:
	type = data.get("type", Type.NOT_ASSIGNED)
	row = data.get("row", 0)
	column = data.get("column", 0)

	var mapPosition = data["position"]
	position = Vector2(mapPosition[0], mapPosition[1])
	selected = data.get("selected", false)
	available = data.get("available", false)

	next_rooms.clear()
	for room_data in data.get("next_rooms", []):
		var room = Room.new()
		room.deserialize(room_data)
		next_rooms.append(room)
