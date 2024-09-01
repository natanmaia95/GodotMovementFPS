extends Node


signal action_added_to_history(score_action:ScoreAction)


const MAX_COMBO_MULTIPLIER : float = 100.0

var action_dict : Dictionary = {}

var action_history : Array[ScoreAction] = []
var total_score : int = 0

var combo_multiplier : float = 1.0
var combo_timer : float = 0.0

var player : FPSController = null


func _ready() -> void:
	_load_actions()
	pass


func _load_actions() -> void:
	var filepaths = Utils.get_all_file_paths("res://resources/combo_actions/")
	for file in filepaths:
		var resource : Resource = load(file)
		assert(resource is ScoreAction)
		var key : String = resource.key
		action_dict[key] = resource


func reset():
	action_history.clear()
	total_score = 0
	combo_multiplier = 1.0
	combo_timer = 0.0
	player = null
	pass


func on_enemy_defeated(enemy:CharacterBody3D) -> void:
	# if-else chain is the best situation here
	# assembly-style programming
	
	if false:
		pass
	
	# parkour eliminations
	elif player.is_in_turnaround:
		push_action("enemy_turnaround_kill")
	elif player.is_wallrunning:
		push_action("enemy_wallrun_kill")
	elif player.is_sliding:
		push_action("enemy_slide_kill")
	elif false:
		pass
	
	# base case?
	else:
		push_action("enemy_kill")
	
	# headshots always increase score so we add them here in a different chain
	var was_headshot = false # not implemented
	if was_headshot: push_action("enemy_headshot")





func push_action(action_key:String) -> void:
	var action = action_dict[action_key.to_lower()]
	assert(action is ScoreAction)
	if not action: return
	
	# increase multiplier on novel action; don't increase on first action.
	if action_history != []:
		var old_action = action_history.back()
		if old_action and old_action != action: increase_multiplier()
	
	action_history.push_back(action)
	action_added_to_history.emit(action)


func increase_multiplier() -> bool:
	# if multiplier >= 10.0: return false # no increase
	combo_multiplier += 0.1
	combo_multiplier = round(combo_multiplier * 10) / 10.0 # fix rounding errors?
	return true
