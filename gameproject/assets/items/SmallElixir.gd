class_name SmallElixir
extends Item

func _init():
	super._init()
	
	description = "Heal yourself by 40 points"
	name = "Small Elixir"


func execute(entity: BaseEntity):
	use_item.emit()
	entity.heal(40)
	turn_ended.emit()
