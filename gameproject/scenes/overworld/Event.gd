extends Node2D

@onready var button: TextureButton = $Button

var color: Color = Color.GRAY

var width: int = 2

var id: int

var children: Array[Node2D] = []

var button_texture: Texture
var target_scene: String = "res://scenes/"

signal buttonPressed(targetScene: String)

func _ready() -> void:
	button.texture_normal = button_texture
	button.material = button.material.duplicate()


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
		draw_line(normal, line, color, width)

func _on_button_mouse_entered() -> void:
	button.material.set_shader_parameter("width", 4)


func _on_button_mouse_exited() -> void:
	button.material.set_shader_parameter("width", 0)


func _on_button_pressed() -> void:
	buttonPressed.emit(target_scene)
	print("HELLO :D")
