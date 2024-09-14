extends ConfigEntry

func get_key() -> String:
	return "vsync"

func get_option_name() -> String:
	return "V-Sync"

func get_option_type() -> OptionType:
	return OptionType.TOGGLE

func get_section() -> String:
	return "GRAPHICS"

func get_possible_values():
	return [true, false]

func get_default_value():
	return true

func on_changed(new_value):
	if new_value == true:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
