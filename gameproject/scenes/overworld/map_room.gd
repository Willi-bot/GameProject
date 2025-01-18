class_name MapRoom
extends Area2D

signal selected(room: Room)

const ICONS := {
	Room.Type.NOT_ASSIGNED: [null, Vector2.ONE],
	Room.Type.MONSTER: [preload("res://imgs/overworld_icons/battle_icon.png"), Vector2.ONE],
	Room.Type.TREASURE: [preload("res://imgs/overworld_icons/coin_icon.png"), Vector2.ONE],
	Room.Type.CAMPFIRE: [preload("res://imgs/overworld_icons/heart_icon.png"), Vector2.ONE],
	Room.Type.SHOP: [preload("res://imgs/overworld_icons/coin_icon.png"), Vector2.ONE],
	Room.Type.BOSS: [preload("res://imgs/overworld_icons/hard_battle_icon.png"), Vector2(1.25, 1.25)],
}

@onready var sprite_2d: Sprite2D = $Visuals/Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var available := false : set = set_available
var room: Room: set = set_room

func set_available(new_value: bool) -> void:
	available = new_value
	room.available = new_value
	
	if available:
		animation_player.play("highlight")
		return

	animation_player.play("RESET")
	

func set_room(new_data: Room) -> void:
	room = new_data
	position = room.position
	sprite_2d.texture = ICONS[room.type][0]
	sprite_2d.scale = ICONS[room.type][1]


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if not available or not event.is_action_pressed("left_mouse"):
		return 
	
	room.selected = true
	selected.emit(room)	
	
