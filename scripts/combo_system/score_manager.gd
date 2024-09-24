extends Node


signal action_added_to_history(score_action:ScoreAction)
signal multiplier_changed

const MAX_COMBO_MULTIPLIER : float = 100.0
const COMBO_TIMER_REFRESH_AMOUNT = 4.0

var action_dict : Dictionary = {}

var action_history : Array[ScoreAction] = []
var total_score : int = 0

var combo_multiplier : float = 1.0
var combo_timer : float = 0.0

var player : FPSController = null
var score_area_detector : ScoreAreaDetectorComponent = null


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


func push_action(action_key:String) -> void:
	var action : ScoreAction = action_dict[action_key.to_lower()]
	assert(action is ScoreAction)
	if not action: return
	# increase multiplier on novel action; don't increase on first action.
	
	if action_history == []:
		extend_combo_timer()
	else:
		if combo_timer <= 0.0 and combo_multiplier == 1.0:
			increase_multiplier()
		elif action.can_combo_into_itself:
			increase_multiplier()
		else:
			var old_action = action_history.back()
			if old_action and old_action != action: 
				increase_multiplier()
	
	action_history.push_back(action)
	award_points(action)
	score_area_detector.increase_trick_count()
	action_added_to_history.emit(action)


func reset():
	action_history.clear()
	total_score = 0
	combo_multiplier = 1.0
	combo_timer = 0.0
	player = null
	pass

func award_points(action:ScoreAction) -> void:
	var score_area_mult = get_score_area_multiplier()
	total_score += floor(combo_multiplier * score_area_mult * action.points) 

func increase_multiplier() -> bool:
	# if multiplier >= 10.0: return false # no increase
	
	if combo_timer <= 0.0:
		extend_combo_timer() # how long before the chain breaks
		combo_multiplier = 1.0
		multiplier_changed.emit()
		return false
	
	extend_combo_timer()
	if get_score_area_multiplier() == 0.0: return false
	
	combo_multiplier += 1.0
	combo_multiplier = round(combo_multiplier * 10) / 10.0 # fix rounding errors?
	multiplier_changed.emit()
	return true

func decrease_multiplier() -> bool:
	if combo_multiplier <= 1.0: 
		combo_multiplier = 1.0
		return false
	# if multiplier >= 10.0: return false # no increase
	combo_timer = 0.5
	combo_multiplier -= 1.0
	combo_multiplier = round(combo_multiplier * 10) / 10.0 # fix rounding errors?
	combo_multiplier = max(combo_multiplier, 1.0)
	multiplier_changed.emit()
	return true

func extend_combo_timer() -> void:
	combo_timer = COMBO_TIMER_REFRESH_AMOUNT

func get_score_area_multiplier() -> float:
	if not score_area_detector: return 1.0
	var area = score_area_detector.get_best_area()
	if area == null: return 0.0
	return area.multiplier

func _physics_process(delta):
	if combo_timer > 0:
		#combo_timer -= delta
		combo_timer -= delta * (1 + combo_multiplier*0.1) # lose combo faster with higher mult
		if combo_timer <= 0:
			decrease_multiplier()




func on_enemy_defeated(_enemy:CharacterBody3D) -> void:
	# if-else chain is the best situation here
	# assembly-style programming
	
	if false:
		pass
	
	# parkour eliminations
	elif player.is_in_turnaround or player.turnaround_timer > 0.01:
		push_action("enemy_turnaround_kill")
	elif player.is_wallrunning:
		push_action("enemy_wallrun_kill")
	elif player.is_vaulting:
		push_action("enemy_vault_kill")
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
