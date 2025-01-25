extends BattleButton
class_name AssetButton

@export var asset: Asset

func initialize(assetEntity: Asset, battle_manager: BattleManager) -> void:
	asset = assetEntity
	description = asset.description
	bm = battle_manager
	asset.bm = battle_manager
	
	if asset.type == Asset.Type.ITEM:
		text = "%s (%d)" % [asset.name, asset.count]
	elif asset.type == Asset.Type.SKILL:
		text = asset.name
		disabled = battle_manager.current_turn.entity.current_mp < asset.mp_cost


func _on_button_pressed(entity: BaseEntity) -> void:
	asset.execute(entity)
