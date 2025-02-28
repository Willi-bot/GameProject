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
	
	entity.health_changed.connect(_process_health_change)
	health_bar.max_value = entity.max_hp
	health_bar.value = entity.current_hp
	var color = get_hp_color(entity.current_hp, entity.max_hp)
	health_bar.self_modulate = color


func start_turn() -> void:
	deal_damage.emit()


func _update_health_indicator() -> void:
	var tween = create_tween()
	tween.tween_property(health_bar, "value", entity.current_hp, 0.5)

	var target_color = get_hp_color(entity.current_hp, entity.max_hp)

	tween.parallel().tween_property(health_bar, "self_modulate", target_color, 0.5)

	await tween.finished


func _process_health_change(is_aoe):
	await _update_health_indicator()
	
	if entity.current_hp == 0:
		entity.death.emit()
		return
	
	if is_aoe:
		entity.damage_processed.emit()
		return 
	
	entity.turn_ended.emit()
	

func _on_character_sprite_pressed() -> void:
	target_enemy.emit(self)


func get_hp_color(current_hp: float, max_hp: float) -> Color:
	current_hp = clamp(current_hp, 0, max_hp)
	var health_percentage = current_hp / max_hp

	var red_intensity = 1.0 - health_percentage
	var green_intensity = health_percentage

	return Color(red_intensity, green_intensity, 0.0)  # No blue component



func set_target(target_icon: AnimatedSprite2D):
	target_icon.global_position = health_bar.global_position
	target_icon.global_position.x += (health_bar.size.x / 4)

func set_active() -> void:
	sprite.material.set_shader_parameter("width", 2)
	
func set_inactive() -> void:
	sprite.material.set_shader_parameter("width", 0)
	sprite.position.y = 0


func set_casting() -> void:
	sprite.position.y += 40


func set_shader_color(color) -> void:
	sprite.material.set_shader_parameter("color", color)


func _on_sprite_mouse_entered() -> void:
	if Global.bm.initiate_negotiation:
		sprite.material.set_shader_parameter("width", 4)


func _on_sprite_mouse_exited() -> void:
	if Global.bm.initiate_negotiation:
		sprite.material.set_shader_parameter("width", 0)
