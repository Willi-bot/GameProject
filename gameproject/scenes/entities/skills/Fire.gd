extends Skill

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func execute() -> void:
	print("Throwing Fireball")
	use_mp()
	var target = battle_manager.get_enemy_target()
	target.entity.be_damaged(40)
	turn_ended.emit()
