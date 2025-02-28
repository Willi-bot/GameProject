class_name PlayerNode
extends Node2D

@export var entity: PlayerEntity

@onready var container: PanelContainer = $Container
@onready var health_bar: ProgressBar = $Container/Info/HealthBar
@onready var current_health: Label = $Container/Info/HealthBar/CurrentHP
@onready var entity_name: Label = $Container/Info/TopRow/Name
@onready var entity_level: Label = $Container/Info/TopRow/Level
@onready var sprite: Sprite2D = $Sprite
@onready var back_sprite: Sprite2D = $BackSprite

@onready var mana_container: Node = $Container/Info/ManaBar
@export var mana_texture: Texture = preload("res://textures/battle/icons/mana_orb.png")
@export var mana_empty_texture: Texture = preload("res://textures/battle/icons/mana_orb_empty.png")

@onready var style_box: StyleBoxFlat
@onready var active_box: StyleBoxFlat

func _ready() -> void:
	entity.health_changed.connect(_process_health_change)
	entity.mp_changed.connect(_update_mana_indicator)
	entity.level_changed.connect(_update_level_indicator)
	entity.death.connect(_set_dead)
	
	_update_level_indicator()
	_update_health_indicator()
	_add_mana_orbs(entity.max_mp)
	_update_mana_indicator()
	
	entity_name.text = entity.name
	
	style_box = container.get_theme_stylebox("panel")
	active_box = style_box.duplicate()
	active_box.set_border_width_all(2)

	health_bar.max_value = entity.max_hp
	health_bar.value = entity.current_hp
	health_bar.self_modulate = get_hp_color(entity.current_hp, entity.max_hp)
	current_health.text = str(entity.current_hp)


func start_turn():
	entity.regen_mp()


func _update_level_indicator():
	entity_level.text = "Lvl: " + str(entity.level)	
	_update_health_indicator()


func _update_health_indicator() -> void:
	current_health.text = str(entity.current_hp)
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
	
	

func _add_mana_orbs(mana_points: int):
	for i in range(mana_points):
		var orb = TextureRect.new()
		orb.texture = mana_empty_texture
		orb.expand_mode = TextureRect.EXPAND_FIT_WIDTH
		mana_container.add_child(orb)

func _update_mana_indicator():
	for i in range(mana_container.get_child_count()):
		var orb = mana_container.get_child(i) as TextureRect
		if i < entity.current_mp:
			orb.texture = mana_texture
		else:
			orb.texture = mana_empty_texture


func _set_dead():
	sprite.self_modulate = Color.BLACK


func get_hp_color(current_hp: float, max_hp: float) -> Color:
	current_hp = clamp(current_hp, 0, max_hp)
	var health_percentage = current_hp / max_hp
	
	var red_intensity = (1.0 - health_percentage / 2)
	var green_intensity = health_percentage
	
	return Color(red_intensity, green_intensity, 0.3)
	
	
func set_active() -> void:
	container.add_theme_stylebox_override("panel", active_box)
	
	
func set_inactive() -> void:
	container.add_theme_stylebox_override("panel", style_box)
	sprite.position.y = 0
	
	
func set_casting() -> void:
	sprite.position.y -= 40
