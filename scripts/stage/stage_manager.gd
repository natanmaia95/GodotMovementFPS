extends Node


var timer : TimerResource = load("res://scripts/timer/level_timer.tres")

## When first entering a level, this should be false (set in the world select, reset on level finish).
## Should be set to true when level's intro cutscene is finished so restarting doesn't trigger it again.
var has_seen_intro := false

## Unused. For respawning if checkpoints are implemented.
var last_checkpoint : int = 0

## This controls if the timer should be counting up.
var is_timer_active := false



func _physics_process(delta):
	if is_timer_active: timer.update(delta)


func start_stage() -> void:
	is_timer_active = true


func reset_stage() -> void:
	has_seen_intro = true
	is_timer_active = false
	timer.reset()
	get_tree().reload_current_scene()


func finish_stage() -> bool:
	if not is_timer_active: return false # no sense in finishing a stage that hasn't started
	
	has_seen_intro = false
	is_timer_active = false
	print_debug("seconds: ", timer.seconds)
	print_debug("frames in seconds: ", timer.get_frames_in_seconds())
	return true
