extends BattleButton
class_name AssetButton

@export var asset: Asset

func initialize(assetEntity: Asset) -> void:
	asset = assetEntity
	description = asset.description
	
	if asset.type == Asset.Type.ITEM:
		text = "%s (%d)" % [asset.name, asset.count]
	elif asset.type == Asset.Type.SKILL:
		text = asset.name
		disabled = Global.bm.current_turn.entity.current_mp < asset.mp_cost


func _on_button_pressed(entity: BaseEntity) -> void:
	asset.execute(entity)
