extends Skill


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func execute(character: Node2D) -> void:
	print("Healing Player")
	character.entity.use_mp(mp_cost)
	var target = await battle_manager.get_player_target()
	var heal_amount = character.entity.intelligence * 2
	target.entity.heal(heal_amount)
	turn_ended.emit()
