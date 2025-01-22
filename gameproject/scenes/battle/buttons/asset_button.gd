extends Button
class_name AssetButton

@export var asset: Asset

func initialize(assetEntity: Asset, battle_manager) -> void:
	asset = assetEntity
	asset.battle_manager = battle_manager
	text = "%s (%d)" % [asset.name, asset.count] if asset.type == Asset.Type.ITEM else asset.name


func _on_button_pressed(entity: BaseEntity) -> void:
	asset.execute(entity)


func _on_mouse_entered(select_icon: TextureRect, info_text: Label) -> void:
	select_icon.visible = true
	select_icon.global_position = global_position
	select_icon.position -= Vector2(
		select_icon.size.x * select_icon.scale.x / 4,
		-select_icon.size.y * select_icon.scale.y / 8
	)
	info_text.text = asset.description


func _on_mouse_exited(info_text: Label) -> void:
	info_text.text = "Choose your next action"
