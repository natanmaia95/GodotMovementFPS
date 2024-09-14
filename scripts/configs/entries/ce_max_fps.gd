extends ConfigEntry

func get_key() -> String:
	return "max_fps"

func get_option_name() -> String:
	return "Max Framerate"

func get_option_type() -> OptionType:
	return OptionType.LIST

func get_section() -> String:
	return "GRAPHICS"

func get_possible_values():
	return [30, 60, 120, "UNLIMITED"]

func get_default_value():
	return 60

func on_changed(new_value):
	if new_value is String and new_value == "UNLIMITED":
		new_value = 0
	Engine.max_fps = new_value
