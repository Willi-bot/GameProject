extends Node2D

@export var entity : BaseEntity

@onready var health_bar: ProgressBar = $HealthBar

signal deal_damage

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	entity.current_hp = entity.max_hp
	entity.health_changed.connect(_update_health_bar)
	
	_update_health_bar()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func start_turn() -> void:
	deal_damage.emit()

func _update_health_bar():
	health_bar.max_value = entity.max_hp
	health_bar.value = entity.current_hp
