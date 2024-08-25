class_name Stage3D
extends Node3D


signal intro_started
signal started


func _ready():
	await ready()
	if not StageManager.has_seen_intro:
		await _intro()
	await _start()
	StageManager.start_stage()

func _intro() -> void:
	intro_started.emit()
	await intro()
	StageManager.has_seen_intro = true
	return

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
