extends MenuBar

@onready var time_label: Label = $Info/GameInfo/TimeContainer/Time/Time
@onready var level_label: Label = $Info/GameInfo/LevelContainer/Level/Level


func _process(delta: float) -> void:
	GlobalState.elapsed_time += delta
	update_elapsed_time_label()

func update_elapsed_time_label() -> void:
	var minutes: int = int(GlobalState.elapsed_time) / 60
	var seconds: int = int(GlobalState.elapsed_time) % 60
	var formatted_time = "%02d:%02d" % [minutes, seconds]
	time_label.text = formatted_time
