class_name Stage3D
extends Node3D


signal intro_started
signal started


@export var player : FPSController = null

@warning_ignore("redundant_await")
func _ready():
	await ready()
	if not StageManager.has_seen_intro:
		await _intro()
	await _start()
	StageManager.start_stage()

@warning_ignore("redundant_await")
func _intro() -> void:
	intro_started.emit()
	await intro()
	StageManager.has_seen_intro = true
	return

@warning_ignore("redundant_await")
func _start() -> void:
	await before_start()
	started.emit()
	return


## Here so you don't override the base class ready
func ready() -> void: pass

## Will run after ready(), only if StageManager.has_seen_intro is false
func intro() -> void: pass

## Will run after ready(), after first_time_start()
func before_start() -> void: pass
