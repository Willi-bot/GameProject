extends Control
class_name Stage


signal response(value: float)

var bm: BattleManager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func set_bm(manager: BattleManager) -> void:
	bm = manager


func _send_response(response_value: float) -> void:
	response.emit(response_value)
