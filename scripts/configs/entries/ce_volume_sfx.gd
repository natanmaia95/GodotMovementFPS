extends ConfigEntry

func get_key() -> String:
	return "volume_sfx"

func get_option_name() -> String:
	return "SFX Volume"

func get_option_type() -> OptionType:
	return OptionType.SLIDER

func get_section() -> String:
	return "AUDIO"

func get_possible_values():
	var range := Range.new()
	range.min_value = 0
	range.max_value = 100
	range.step = 5
	return range

func get_default_value():
	return 50

func on_changed(new_value):
	# buffer index 0 is master, i think
	var value_in_db = linear_to_db(new_value / 100.0)
	var sfx_bus = AudioServer.get_bus_index("SFX")
	if sfx_bus == -1:
		printerr("Audio bus \"SFX\" does not exist")
	AudioServer.set_bus_volume_db(sfx_bus, value_in_db)
