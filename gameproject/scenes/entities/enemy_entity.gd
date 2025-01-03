extends Node2D

@export var entity : BaseEntity

@onready var health_bar: ProgressBar = $HealthBar
@onready var sprite: Sprite2D = $Sprite
@onready var target_area: Area2D = $TargetArea
@onready var collision_box: CollisionShape2D = $TargetArea/CollisionBox

@export var list_id: int

signal deal_damage
signal target_enemy(id: int)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	entity.current_hp = entity.max_hp
	entity.health_changed.connect(_update_health_bar)
	
	var sprite_size = sprite.texture.get_size()
	var rect = RectangleShape2D.new()
	rect.extents = sprite_size
	
	collision_box.shape = rect
	target_area.mouse_entered.connect(_mouse_entered)
	
	_update_health_bar()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func start_turn() -> void:
	deal_damage.emit()

func _update_health_bar() -> void:
	health_bar.max_value = entity.max_hp
	health_bar.value = entity.current_hp
	
	
func _mouse_entered() -> void:
	print("Mouse entered")
	print(list_id)
	target_enemy.emit(list_id)
