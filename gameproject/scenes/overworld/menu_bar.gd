extends MenuBar

@onready var time_label: Label = $Info/GameInfo/TimeContainer/TimeBox/Time
@onready var level_label: Label = $Info/GameInfo/LevelContainer/LevelBox/Level
@onready var player_name: Label = $Info/PlayerInfo/NameContainer/NameBox/Name
@onready var health_label: Label = $Info/PlayerInfo/HealthContainer/HealthBox/Health

func _ready() -> void:
	update_level_label()
	set_player_name()
	update_health_label()
	
func _process(delta: float) -> void:
	GlobalState.elapsed_time += delta
	update_elapsed_time_label()

func update_elapsed_time_label() -> void:
	var minutes: int = int(GlobalState.elapsed_time) / 60
	var seconds: int = int(GlobalState.elapsed_time) % 60
	var formatted_time = "%02d:%02d" % [minutes, seconds]
	time_label.text = formatted_time

func update_level_label() -> void:
	level_label.text = "%02d" % [GlobalState.current_level]

func set_player_name() -> void:
	player_name.text = GlobalState.player_name

func update_health_label() -> void:
	health_label.text = str(GlobalState.current_hp).pad_zeros(2) + "/" + str(GlobalState.max_hp).pad_zeros(2)
