extends Node2D

@export var entity: BaseEntity
@export var scale_factor: float

@onready var current_health: Label = $PanelContainer/PlayerInfo/Health/CurrentHP
@onready var max_health: Label = $PanelContainer/PlayerInfo/Health/MaxHP
@onready var entity_name: Label = $PanelContainer/PlayerInfo/Name
@onready var sprite: Sprite2D = $CharacterSprite


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	entity = entity.duplicate()
	
	entity.current_hp = entity.max_hp
	entity.health_changed.connect(_update_health_indicator)
	
	max_health.text = str(entity.max_hp)
	current_health.text = str(entity.current_hp)
	entity_name.text = entity.name


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func start_turn() -> void:
	pass

func _update_health_indicator():
	max_health.text = str(entity.max_hp)
	current_health.text = str(entity.current_hp)
