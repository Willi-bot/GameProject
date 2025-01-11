extends Button
class_name SkillButton


@export var skill_resource: Resource


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass





func _on_button_pressed(target):
	# Execute logic based on the associated resource
	if skill_resource:
		print("Executing move:", skill_resource.name)
		skill_resource.start_attacking(target)


func _on_mouse_entered(select_icon: TextureRect) -> void:
	select_icon.visible = true
	select_icon.global_position = global_position

	select_icon.position.y += (select_icon.size.y * select_icon.scale.y) / 8
	select_icon	.position.x -= (select_icon.size.x * select_icon.scale.x) / 4
