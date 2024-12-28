extends Node2D

@export var entity : BaseEntity

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
	print("Health indicator needs to be updated!")	
