class_name PlayerEntity
extends Node2D

@export var entity: BaseEntity

@onready var health_bar: ProgressBar = $Container/Info/HealthBar
@onready var current_health: Label = $Container/Info/HealthBar/CurrentHP
@onready var entity_name: Label = $Container/Info/Name
@onready var sprite: Sprite2D = $Sprite
@onready var back_sprite: Sprite2D = $BackSprite

@onready var mana_container: Node = $Container/Info/ManaBar
@export var mana_texture: Texture = preload("res://textures/battle/icons/mana_orb.png")
@export var mana_empty_texture: Texture = preload("res://textures/battle/icons/mana_orb_empty.png")

func _ready() -> void:
	entity.health_changed.connect(_update_health_indicator)
	entity.mp_changed.connect(_update_mana_indicator)
	
	_update_health_indicator()
	_add_mana_orbs(entity.max_mp)
	_update_mana_indicator()
	
	entity_name.text = entity.name
	
	
func _process(delta: float) -> void:
	pass

func start_turn() -> void:
	pass

func _update_health_indicator():
	health_bar.max_value = entity.max_hp
	health_bar.value = entity.current_hp
	var color = get_hp_color(entity.current_hp, entity.max_hp)
	health_bar.self_modulate = color
	current_health.text = str(entity.current_hp)
	

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

func get_hp_color(current_hp: float, max_hp: float) -> Color:
	current_hp = clamp(current_hp, 0, max_hp)
	var health_percentage = current_hp / max_hp
	
	var red_intensity = (1.0 - health_percentage / 2)
	var green_intensity = health_percentage
	
	return Color(red_intensity, green_intensity, 0.3)
	
	
func set_active() -> void:
	sprite.position.y -= 40
	
	
func set_inactive() -> void:
	sprite.position.y += 40
