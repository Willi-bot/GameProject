class_name EnemyNode
extends Node2D

@export var entity: EnemyEntity
@export var scale_factor: float

@onready var health_bar: ProgressBar = $HealthBar
@onready var sprite: Sprite2D = $Sprite

signal deal_damage
signal target_enemy(e: Node2D)


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

func set_target(target_icon: AnimatedSprite2D):
	target_icon.global_position = health_bar.global_position
	target_icon.global_position.x += (health_bar.size.x / 4)

func set_active() -> void:
	sprite.material.set_shader_parameter("width", 2)
	
func set_inactive() -> void:
	sprite.material.set_shader_parameter("width", 0)


func set_shader_color(color) -> void:
	sprite.material.set_shader_parameter("color", color)


func _on_sprite_mouse_entered() -> void:
	if Global.bm.initiate_negotiation:
		sprite.material.set_shader_parameter("width", 4)


func _on_sprite_mouse_exited() -> void:
	if Global.bm.initiate_negotiation:
		sprite.material.set_shader_parameter("width", 0)
