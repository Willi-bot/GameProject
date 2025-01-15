extends Button
class_name SkillButton


@export var skill: Skill


func initialize(skill_name: String, battle_manager) -> void:
	var path = "res://scenes/entities/skills/" + skill_name + ".tscn"
	skill = load(path).instantiate()
	skill.battle_manager = battle_manager

func _on_button_pressed(battle_manager):
	if skill:
		skill.execute()


func _on_mouse_entered(select_icon: TextureRect, info_text: Label) -> void:
	select_icon.visible = true
	select_icon.global_position = global_position

	select_icon.position.y += (select_icon.size.y * select_icon.scale.y) / 8
	select_icon	.position.x -= (select_icon.size.x * select_icon.scale.x) / 4
	
	info_text.text = skill.description
	
	
func _on_mouse_exited(info_text: Label) -> void:
	info_text.text = "Choose your next action"
