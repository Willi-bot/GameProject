extends Button
class_name ItemButton


@export var item: Item


func initialize(item_name: String, battle_manager) -> void:
	var path = "res://scenes/entities/asset/items/" +  item_name + ".tscn"
	skill = load(path).instantiate()
	skill.battle_manager = battle_manager

func _on_button_pressed(character: Node2D):
	if skill:
		skill.execute(character)


func _on_mouse_entered(select_icon: TextureRect, info_text: Label) -> void:
	select_icon.visible = true
	select_icon.global_position = global_position

	select_icon.position.y += (select_icon.size.y * select_icon.scale.y) / 8
	select_icon	.position.x -= (select_icon.size.x * select_icon.scale.x) / 4
	
	info_text.text = skill.description
	
	
func _on_mouse_exited(info_text: Label) -> void:
	info_text.text = "Choose your next action"
