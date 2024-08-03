extends ConfigEntry

func get_key() -> String:
	return "volume_master"

func get_section() -> String:
	return "AUDIO"

func get_possible_values():
	return range(0,101,1)

func get_default_value():
	return 50

func on_changed(new_value):
	# buffer index 0 is master, i think
	var value_in_db = linear_to_db(new_value / 100)
	AudioServer.set_bus_volume_db(0, value_in_db)
