extends Node


signal stage_info_loaded()


## String -> StageInfo
var stages_list : Dictionary = {}

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
	get_tree().change_scene_to_packed(stage_info.stage_packed_scene)


func start_stage() -> void:
	is_timer_active = true
	is_stage_finished = false


func reset_stage() -> void:
	_reset_stage_components()
	get_tree().reload_current_scene()


func _reset_stage_components() -> void:
	has_seen_intro = true
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
	print_debug("seconds: ", timer.seconds)
	print_debug("frames in seconds: ", timer.get_frames_in_seconds())
	return true


func exit_stage(target_scene:PackedScene = null) -> void:
	_reset_stage_components()
	if target_scene == null: #default
		target_scene = load("res://scenes/screens/stage_select/stage_select_debug.tscn")
	get_tree().change_scene_to_packed(target_scene)


func _load_all_stage_info() -> void:
	var files = Utils.get_all_file_paths("res://resources/stage_info/")
	for file_name in files:
		var resource = ResourceLoader.load(file_name)
		if not resource is StageInfo: continue
		var stage_info : StageInfo = resource as StageInfo
		stages_list[stage_info.key] = stage_info
	stage_info_loaded.emit()
