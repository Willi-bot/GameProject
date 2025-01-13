extends Node2D

@export var entity: BaseEntity
@export var scale_factor: float

@onready var health_bar: ProgressBar = $HealthBar
@onready var sprite: TextureButton = $CharacterSprite

@export var list_id: int

signal deal_damage
signal target_enemy(id: int)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	entity = entity.duplicate()
	
	entity.health_changed.connect(_update_health_bar)
	
	_update_health_bar()

	
func init() -> void:	
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func start_turn() -> void:
	deal_damage.emit()

func _update_health_bar() -> void:
	health_bar.max_value = entity.max_hp
	health_bar.value = entity.current_hp

func _on_character_sprite_pressed() -> void:
	target_enemy.emit(list_id)
