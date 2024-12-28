extends Node2D

@export var entity : BaseEntity

@onready var current_health: Label = $PanelContainer/PlayerInfo/Health/CurrentHP
@onready var max_health: Label = $PanelContainer/PlayerInfo/Health/MaxHP


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	entity.current_hp = entity.max_hp
	entity.health_changed.connect(_update_health_indicator)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func start_turn() -> void:
	pass

func _update_health_indicator():
	max_health.text = str(entity.max_hp)
	current_health.text = str(entity.current_hp)
