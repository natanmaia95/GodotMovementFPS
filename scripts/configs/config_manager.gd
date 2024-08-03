extends Node


var entries : Dictionary = {}
var config_file : ConfigFile = ConfigFile.new()


func _ready():
	load_entries()
	var err = load_config_file()
	if err != OK:
		config_file = make_new_configs()
		save_config_file()
	apply_all_configs()


func set_config(config_key:String, new_value) -> void:
	var entry : ConfigEntry = entries[config_key]
	if entry:
		config_file.set_value(entry.get_section(), entry.get_key(), new_value)
		_on_config_changed(entry,new_value)
	else:
		printerr("Couldn't find ConfigEntry of key \"%s\"" % config_key)
	# temporary, save the entire file per change.
	# TODO: only save on "Apply Changes"
	save_config_file()


func _on_config_changed(entry:ConfigEntry, new_value) -> void:
	entry.on_changed(new_value)


func load_entries() -> void:
	var files = Utils.get_all_file_paths("res://scripts/configs/entries")
	print_debug(files)
	for file_name in files:
		var resource = ResourceLoader.load(file_name)
		if not resource is Script: continue
		
		var script = resource as Script
		var entry : ConfigEntry = script.new()
		entries[entry.get_key()] = entry
		entry.manager = self


func load_config_file() -> Error:
	var err = config_file.load("user://configs.cfg")
	if err != OK:
		print("config file not found / corrupted, making new config file...")
	else:
		print("config file loaded!")
		# check if all values exist, create ones that don't exist.
		for entry : ConfigEntry in entries.values():
			if not config_file.has_section_key(entry.get_section(), entry.get_key()):
				config_file.set_value(entry.get_section(), entry.get_key(), entry.get_default_value())
				print("Added config default values for \"%s\"." % entry.get_key())
	return err


func save_config_file() -> Error:
	var err = config_file.save("user://configs.cfg")
	if err != OK:
		push_error("config file could not be saved: ", err)
	else:
		print("config file saved!")
	return err


func make_new_configs() -> ConfigFile:
	var new_configs := ConfigFile.new()
	for entry : ConfigEntry in entries.values():
		#print_rich(entry)
		new_configs.set_value(entry.get_section(), entry.get_key(), entry.get_default_value())
	print("Made new default configs from scratch.")
	return new_configs


func apply_all_configs() -> void:
	for entry : ConfigEntry in entries.values():
		var value = config_file.get_value(entry.get_section(), entry.get_key(), entry.get_default_value())
		_on_config_changed(entry, value)


func get_all_entries():
	return entries.values()
