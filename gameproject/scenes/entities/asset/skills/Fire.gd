extends Skill

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func execute(character: Node2D) -> void:
	print("Throwing Fireball")
	character.entity.use_mp(mp_cost)
	var target = battle_manager.selected_target
	var damage = character.entity.intelligence * 2
	target.entity.be_damaged(damage)
	turn_ended.emit()
