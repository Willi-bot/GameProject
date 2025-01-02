extends Node2D

@onready var button : TextureButton = $Button


const margin = 5

var children: Array = []

func _ready() -> void:
	var textures = [
		preload("res://imgs/overworld_icons/coin.png"),
		preload("res://imgs/overworld_icons/battle_icon.png"),
		preload("res://imgs/overworld_icons/question_mark_icon.png")
	]
	
	var random_index = randi() % textures.size()  # Get a random index between 0 and 2
	button.texture_normal = textures[random_index]  # Assign the selected texture to the button

	
func add_child_event(child):
	if !children.has(child):
		children.append(child)
		queue_redraw()

func _draw():

	for child in children:
		var line = child.position - position
		
		var normal = line.normalized()
		line -= margin * normal
		var color = Color.GRAY
		
		#print(normal * margin, line)
		
		draw_line(normal * margin, line, color, 2, true)


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/battle/battle.tscn")
