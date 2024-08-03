extends ConfigEntry

func get_key() -> String:
	return "is_fullscreen"

func get_section() -> String:
	return "GRAPHICS"

func get_possible_values():
	return [true, false]

func get_default_value():
	return true

func on_changed(new_value):
	var window = manager.get_window()
	window.mode = Window.MODE_FULLSCREEN if new_value == true else Window.MODE_WINDOWED
	window.size = window.size
	#if new_value == false: window.size = Vector2i(800,600)
	window.move_to_center()
