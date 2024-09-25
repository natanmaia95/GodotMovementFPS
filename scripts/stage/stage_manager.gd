extends Node


signal stage_info_loaded()
signal stage_finished()

## String -> StageInfo
var stages_list : Dictionary = {}

## Use this to get the stage key for whatever purpose
## Also useful to select which stage comes next!
var current_stage_info : StageInfo = null

## Dict generated from StageRecord.make_best_of(new, old)
var current_stage_results = null

var timer : TimerResource = load("res://scripts/timer/level_timer.tres")

## When first entering a level, this should be false (set in the world select, reset on level finish).
## Should be set to true when level's intro cutscene is finished so restarting doesn't trigger it again.
var has_seen_intro := false

## Unused. For respawning if checkpoints are implemented.
var last_checkpoint : int = 0

## This controls if the timer should be counting up.
var is_timer_active := false

var is_stage_finished := false




func _ready():
	_load_all_stage_info()


func _physics_process(delta):
	if is_timer_active: timer.update(delta)


func goto_stage(stage_key:String) -> void:
	var stage_info : StageInfo = stages_list[stage_key]
	if not stage_info: 
		printerr("COULDNT FIND STAGE IN LOADED INFO???")
		return
	
	if stage_info.stage_packed_scene == null:
		printerr("COULDNT FIND PACKED STAGE")
		return
	
	_reset_stage_components()
	current_stage_info = stage_info
	has_seen_intro = false
	get_tree().change_scene_to_packed(stage_info.stage_packed_scene)


func start_stage() -> void:
	is_timer_active = true
	is_stage_finished = false


func reset_stage() -> void:
	_reset_stage_components()
	get_tree().reload_current_scene()


func _reset_stage_components() -> void:
	#has_seen_intro = true
	current_stage_results = null
	is_timer_active = false
	is_stage_finished = false
	timer.reset()
	ScoreManager.reset()
	get_tree().paused = false
	Engine.time_scale = 1.0
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func finish_stage() -> bool:
	if not is_timer_active: 
		return false # no sense in finishing a stage that hasn't started
	
	is_stage_finished = true
	is_timer_active = false
	
	_save_records()
	
	stage_finished.emit()
	return true


func exit_stage(target_scene:PackedScene = null) -> void:
	_reset_stage_components()
	current_stage_info = null
	if target_scene == null: #default
		target_scene = load("res://scenes/screens/stage_select/stage_select_debug.tscn")
	get_tree().change_scene_to_packed(target_scene)


func _save_records() -> void:
	if not current_stage_info: return
	# compute results
	var new_record := StageRecord.from_dict({
		"time": timer.ticks,
		"score": ScoreManager.total_score
	})
	var old_record_data = SaveManager.get_data("stage_records/" + current_stage_info.key)
	if old_record_data == null: 
		print_debug("Records data for '%s' not found, making new data." % current_stage_info.key)
		old_record_data = {}
	var old_record := StageRecord.from_dict(old_record_data)
	
	current_stage_results = StageRecord.make_best_of(new_record, old_record)
	# save best
	SaveManager.set_data(
		"stage_records/" + current_stage_info.key, 
		current_stage_results["best_record"].to_dict()
	)
	SaveManager.save_data()


func _load_all_stage_info() -> void:
	var files = Utils.get_all_file_paths("res://resources/stage_info/")
	for file_name in files:
		var resource = ResourceLoader.load(file_name)
		if not resource is StageInfo: continue
		var stage_info : StageInfo = resource as StageInfo
		stages_list[stage_info.key] = stage_info
	stage_info_loaded.emit()
