extends Asset
class_name Skill

@export var mp_cost: int

var animation: PackedScene
var animation_scene: AnimatedSprite2D
var timer: Timer
var target

func _init() -> void:
	type = Asset.Type.SKILL

func execute(entity: BaseEntity) -> void:
	super(entity)
