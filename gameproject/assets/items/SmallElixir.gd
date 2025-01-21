class_name SmallElixir
extends Item

func _init():
	name = "Small Elixir"
	description = "Heal yourself by 40 points"


func execute(character: Node2D):
	use_item.emit()
	character.entity.heal(40)
	turn_ended.emit()
