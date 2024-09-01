class_name BasePauseScreen
extends CanvasLayer

var is_open := false
var is_busy := false


func _ready():
	process_mode = PROCESS_MODE_ALWAYS


func _input(event:InputEvent):
	if not is_busy and event.is_action("pause") and event.is_pressed():
		if is_open:
			_close()
		else:
			_open()
		get_viewport().set_input_as_handled()


func _open() -> void:
	is_busy = true
	get_tree().paused = true
	await open()
	is_open = true
	is_busy = false


func _close() -> void:
	is_busy = true
	await close()
	get_tree().paused = false
	is_open = false
	is_busy = false


# Overridable function
func open() -> void:
	return

# Overridable function
func close() -> void:
	return