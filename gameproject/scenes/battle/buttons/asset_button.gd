extends Button
class_name AssetButton

@export var asset: Asset

func initialize(assetEntity: Asset, battle_manager: BattleManager) -> void:
	asset = assetEntity
	asset.battle_manager = battle_manager
	if asset.type == Asset.Type.ITEM:
		text = "%s (%d)" % [asset.name, asset.count]
	elif asset.type == Asset.Type.SKILL:
		text = asset.name
		disabled = battle_manager.current_turn.entity.current_mp < asset.mp_cost
	

func _on_button_pressed(entity: BaseEntity) -> void:
	asset.execute(entity)


func _on_mouse_entered() -> void:
	set_active_button(asset.battle_manager.select_icon, asset.battle_manager.info_text)


func _on_focus_entered() -> void:
	set_active_button(asset.battle_manager.select_icon, asset.battle_manager.info_text)


func _on_focus_exited() -> void:
	asset.battle_manager.info_text.text = "Choose your next action"

func _on_mouse_exited() -> void:
	asset.battle_manager.info_text.text = "Choose your next action"



func set_active_button(select_icon: TextureRect, info_text: Label):
	select_icon.visible = true
	select_icon.global_position = global_position
	select_icon.position -= Vector2(
		select_icon.size.x * select_icon.scale.x / 4,
		-select_icon.size.y * select_icon.scale.y / 8
	)
	info_text.text = asset.description
