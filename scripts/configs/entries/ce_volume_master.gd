extends ConfigEntry

func get_key() -> String:
	return "volume_master"

func get_option_name() -> String:
	return "Master Volume"

func get_option_type() -> OptionType:
	return OptionType.SLIDER

func get_section() -> String:
	return "AUDIO"

func get_possible_values():
	var r := Range.new()
	r.min_value = 0
	r.max_value = 100
	r.step = 5
	return r

func get_default_value():
	return 50

func on_changed(new_value):
	# buffer index 0 is master, i think
	var value_in_db = linear_to_db(new_value / 100.0)
	AudioServer.set_bus_volume_db(0, value_in_db)
