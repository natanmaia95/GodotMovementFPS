extends ConfigEntry

func get_key() -> String:
	return "volume_music"

func get_option_name() -> String:
	return "Music Volume"

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
	var music_bus = AudioServer.get_bus_index("MUSIC")
	if music_bus == -1:
		printerr("Audio bus \"MUSIC\" does not exist")
	AudioServer.set_bus_volume_db(music_bus, value_in_db)
