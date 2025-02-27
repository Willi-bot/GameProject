class_name FairyTear
extends Item

func _init():
	super._init()
	
	description = "Fully restore mana to player character"
	name = "Fairy Tear"


func execute(entity: BaseEntity):
	super(entity)
	
	Global._update_item_count(self)
	entity.current_mp = entity.max_mp
	entity.mp_changed.emit()
	turn_ended.emit()
