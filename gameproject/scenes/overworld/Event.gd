extends Node2D

@onready var button: TextureButton = $Button

var color: Color = Color.GRAY
var width: int = 2
var use_antialiasing: bool = false

var children: Array[Node2D] = []

var button_texture: Texture
var target_scene: String = "res://scenes/"

func _ready() -> void:
	button.texture_normal = button_texture

func set_event_type(event_name: String, texture: Texture) -> void:
	button_texture = texture
	target_scene += "%s/%s.tscn" % [event_name, event_name]


func add_child_event(child: Node2D) -> void:
	if not children.has(child):
		children.append(child)
		queue_redraw()

func _draw() -> void:
	for child in children:
		var line = child.position - position
		var normal = line.normalized()
		line -= normal
		draw_line(normal, line, color, width, use_antialiasing)

func _on_button_pressed() -> void:
	print("Button pressed: ", target_scene)
	get_tree().change_scene_to_file(target_scene)
