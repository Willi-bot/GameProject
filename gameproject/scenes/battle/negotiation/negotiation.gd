extends Control
class_name Negotiation

@onready var stage_container = $"StageContainer"

@onready var foo = $"foo"

@onready var stage_scene = preload("res://scenes/battle/negotiation/stages/DemandHealth.tscn")

var bm: BattleManager
var success_chance: float
var stages: Array = []
var current_stage: int = 0

signal negotiation_end(success: bool)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# TODO determine the amount of stages
	var stages_amount = 3
	
	# for each stage randomly choose whether it is a demand, prompt or swap/kill and add it to list
	# of stages
	for i in range(stages_amount):
		var stage: Stage = stage_scene.instantiate()
		stage.set_bm(bm)
		stages.append(stage)
		stage.response.connect(_process_response)
	
	foo.text = str(success_chance)
	
	# show first stage
	_show_stage(stages[0])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func set_negotiation_partner(manager, probability) -> void:
	bm = manager
	success_chance = probability


func _show_stage(stage) -> void:
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
	if current_stage == len(stages):
		# passed through last stage go to end of negotiation
		var rn = randf()
		if rn <= success_chance:
			print("Success")
			negotiation_end.emit(true)
		else:
			print("Failure")
			negotiation_end.emit(false)
		return
		
	_show_stage(stages[current_stage])
