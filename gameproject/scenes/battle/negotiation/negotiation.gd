extends Control
class_name Negotiation

@onready var stage_container = $"StageContainer"

@onready var foo = $"foo"

var stage_scene
var success_chance: float
var stages: Array = []
var current_stage: int = 0
var stages_amount: int

var stage_categories: Array = ["DemandHealth", "TakeAction", "DemandGold"]

signal negotiation_end(success: bool)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# TODO determine the amount of stages
	stages_amount = 3
	
	foo.text = str(success_chance)
	
	# show first stage
	_show_next_stage()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	
func set_success_chance(chance: float) -> void:
	success_chance = chance


func _show_next_stage() -> void:
	# for each stage randomly choose whether it is a demand, prompt or swap/kill
	var stage_type = stage_categories[randi_range(0, len(stage_categories) - 1)]
	stage_scene = load("res://scenes/battle/negotiation/stages/%s.tscn" % stage_type)
	
	var stage: Stage = stage_scene.instantiate()
	stage.response.connect(_process_response)
	
	stage_container.add_child(stage)
	
	
func _process_response(value: float) -> void:
	success_chance = clamp(success_chance + value, 0., 1.)
	foo.text = str(success_chance)
	
	# remove current stage
	stage_container.remove_child(stage_container.get_child(0))
	
	if is_zero_approx(abs(success_chance - 1.)): # check if success chance == 1.
		print("Success")
		negotiation_end.emit(true)
		return
	
	if is_zero_approx(success_chance): # check if success chance == 0.
		print("Failure")
		negotiation_end.emit(false)
		return
	
	current_stage += 1
	if current_stage == stages_amount:
		# passed through last stage go to end of negotiation
		if randf() <= success_chance:
			print("Success")
			negotiation_end.emit(true)
		else:
			print("Failure")
			negotiation_end.emit(false)
	else:
		_show_next_stage()
