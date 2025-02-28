class_name Heal
extends Skill

func _init():
	super._init()
	
	name = "Heal"
	description = "Heal za ally :DDD"
	animation = preload("res://textures/animations/heal_animation.tscn")


func execute(entity: BaseEntity) -> void:
	super(entity)
	
	entity.use_mp(mp_cost)
	target = await Global.bm.get_player_target()
	
	selection_finished.emit()
	
	var heal_amount = entity.intelligence * 2
	target.entity.heal(heal_amount)
	animation_scene = animation.instantiate() as AnimatedSprite2D
	target.sprite.add_child(animation_scene)
	animation_scene.play()
	
	timer = Timer.new()
	timer.wait_time = 0.75
	timer.timeout.connect(timer_timeout)
	target.add_child(timer)
	timer.start()


func timer_timeout() -> void:
	target.sprite.remove_child(animation_scene)
	target.remove_child(timer)
	turn_ended.emit()
