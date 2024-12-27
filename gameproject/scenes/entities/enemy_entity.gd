extends Node2D

@export var entity : BaseEntity

signal deal_damage

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	entity.current_hp = entity.max_hp


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func start_turn() -> void:
	deal_damage.emit()
