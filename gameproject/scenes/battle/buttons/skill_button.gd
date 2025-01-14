extends Button
class_name SkillButton


@export var skill: Skill


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed():
	# Execute logic based on the associated resource
	if skill:
		print("Executing move:", skill.name)
		skill.execute()


func _on_mouse_entered(select_icon: TextureRect, info_text: Label) -> void:
	select_icon.visible = true
	select_icon.global_position = global_position

	select_icon.position.y += (select_icon.size.y * select_icon.scale.y) / 8
	select_icon	.position.x -= (select_icon.size.x * select_icon.scale.x) / 4
	
	info_text.text = skill.description
	
	
func _on_mouse_exited(info_text: Label) -> void:
	info_text.text = "Choose your next action"
