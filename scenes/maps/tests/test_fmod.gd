extends Stage3D

@onready var event_emitter : FmodEventEmitter3D = $FmodEventEmitter3D
var is_on_fire = false

func ready():
	FmodServer
	event_emitter.play()
	pass


func _input(event):
	if event is InputEventKey:
		var key_event := event as InputEventKey
		if key_event.keycode == KEY_SPACE and key_event.pressed and not key_event.is_echo():
			
			var initial_value = 0.0 if not is_on_fire else 1.0
			var final_value = 1.0 if not is_on_fire else 0.0
			
			var tween = create_tween()
			tween.tween_method(_tween_parameter_callback.bind("on_fire"), initial_value, final_value, 1.0)
			is_on_fire = !is_on_fire


# invert param order for bind to work
func _tween_parameter_callback(value, param_name) -> void:
	event_emitter.set_parameter(param_name, value)
