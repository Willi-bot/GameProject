extends Skill


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func execute() -> void:
	print("Sweeping all enemies")
	use_mp()
	var targets = battle_manager.get_all_enemies()
	for target in targets:
		target.entity.be_damaged(80)
	turn_ended.emit()
	
