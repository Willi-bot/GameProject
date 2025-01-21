class_name MapRoom
extends Area2D

signal selected(room: Room)

const ICONS := {
	Room.Type.NOT_ASSIGNED: [null, Vector2.ONE],
	Room.Type.MONSTER: [preload("res://textures/overworld/icons/battle.png"), Vector2.ONE],
	Room.Type.SUPRISE: [preload("res://textures/overworld/icons/question_mark.png"), Vector2.ONE],
	Room.Type.CAMPFIRE: [preload("res://textures/overworld/icons/heart.png"), Vector2.ONE],
	Room.Type.SHOP: [preload("res://textures/overworld/icons/coin.png"), Vector2.ONE],
	Room.Type.BOSS: [preload("res://textures/overworld/icons/hard_battle.png"), Vector2(3, 3)],
}

@onready var sprite_2d: Sprite2D = $Visuals/Sprite2D
@onready var line_2d: Line2D = $Visuals/Line2D
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

func mark_selected():
	var random_rotation = randf() * 360
	line_2d.rotation = random_rotation
	line_2d.show()
	
func mark_inactive():
	var shader = load("res://shaders/sprite_grayscale.gdshader")
	
	var newMaterial = ShaderMaterial.new()
	newMaterial.shader = shader

	sprite_2d.material = newMaterial
	
	
func set_room(new_data: Room) -> void:
	room = new_data
	position = room.position
	sprite_2d.texture = ICONS[room.type][0]
	sprite_2d.scale = ICONS[room.type][1]


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if not available or not event.is_action_pressed("left_mouse"):
		return 
	
	mark_selected()
	
	room.selected = true
	selected.emit(room)	
	
