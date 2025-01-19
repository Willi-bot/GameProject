extends Node2D

@export var entity: BaseEntity
@export var scale_factor: float

@onready var health_bar: ProgressBar = $HealthBar
@onready var sprite: Sprite2D = $Sprite
@onready var target_icon: TextureRect = $TargetIcon

signal deal_damage
signal target_enemy(id: int)


func _ready() -> void:
	sprite.material = sprite.material.duplicate()
	
	entity.health_changed.connect(_update_health_bar)
	
	_update_health_bar()

func start_turn() -> void:
	deal_damage.emit()

func _update_health_bar() -> void:
	health_bar.max_value = entity.max_hp
	health_bar.value = entity.current_hp

func _on_character_sprite_pressed() -> void:
	target_enemy.emit(self)

func set_active() -> void:
	sprite.material.set_shader_parameter("width", 2)
	
func set_inactive() -> void:
	sprite.material.set_shader_parameter("width", 0)
