extends Skill


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func execute() -> void:
	print("Healing Player")
	var target = await battle_manager.get_player_target()
	target.entity.heal(40)
	turn_ended.emit()
