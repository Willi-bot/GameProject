class_name Fireball
extends Skill


func _init():
	super._init()
	
	name = "Fireball"
	description = "Shoot za fireball"
	mp_cost = 2
	animation = preload("res://textures/animations/fireball_animation.tscn")


func execute(entity: BaseEntity) -> void:
	super(entity)
	
	entity.use_mp(mp_cost)
	target = Global.bm.selected_target
	var damage = entity.intelligence / 10
	animation_scene = animation.instantiate() as AnimatedSprite2D
	target.add_child(animation_scene)
	animation_scene.play()
	
	animation_scene.animation_finished.connect(end_turn.bind(damage))

	

func end_turn(damage: float):
	target.entity.be_damaged(damage)
	target.remove_child(animation_scene)
	turn_ended.emit()
