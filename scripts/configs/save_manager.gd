extends Node

const encryption_key := "Gu4r4hLind0!"
var data := {}

func _ready():
	setup_default_data()
	var _err = load_data()
	set_data("records/total_score", 2300)
	save_data()

func load_data():
	#load_from_json()
	load_from_file(true)
	pass

func save_data():
	#save_to_json()
	save_to_file(true)
	pass

## Please inst_to_dict your values first.
func set_data(key:String, value) -> void:
	assert(not value is Object)
	_set_data(key, value)

func get_data(key:String):
	return _get_data(key)


func _set_data(key:String, value, dict=data) -> void:
	var split_key = key.split("/", false, 1)
	if split_key.size() == 1:
		if not dict.has(key):
			dict[key] = value
		elif value is Dictionary and dict[key] is Dictionary:
			dict[key].merge(value, true)
			print("merged contents")
		else:
			dict[key] = value
		return
	else:
		if not dict[split_key[0]] is Dictionary:
			dict[split_key[0]] = {}
		_set_data(split_key[1], value, dict[split_key[0]])
		return

func _get_data(key:String, dict=data):
	var split_key = key.split("/", false, 1)
	if not dict.has(split_key[0]): 
		return null
	elif split_key.size() == 1:
		return dict[split_key[0]]
	else:
		var result = _get_data(split_key[1], dict[split_key[0]])
		if result == null and dict == data:
			printerr("Couldn't find data at key: '%s'" % key)
		return result

func _load_values_to_data_dict(savegame_dict:Dictionary) -> void:
	data.merge(savegame_dict, true)
	#TODO find a way to merge recursively

## Custom Implementation

func setup_default_data() -> void:
	data["records"] = {
		"total_score": 1000
	}
	data["collectables"] = {}
	data["unlockables"] = {}

func load_from_json() -> Error:
	var file_contents : String = FileAccess.get_file_as_string("user://save_game.json")
	if file_contents == "":
		return FileAccess.get_open_error()
	var dict = JSON.parse_string(file_contents)
	print_debug(dict)
	if dict == null:
		return ERR_PARSE_ERROR
	_load_values_to_data_dict(dict)
	return OK

func save_to_json() -> Error:
	var json_string = JSON.stringify(data, "\t")
	var file_access = FileAccess.open("user://save_game.json", FileAccess.WRITE)
	file_access.store_string(json_string)
	return OK

func load_from_file(encrypted:bool=false) -> Error:
	var file_access : FileAccess
	if encrypted:
		file_access = FileAccess.open_encrypted_with_pass("user://save_game.dat", FileAccess.READ, encryption_key)
	else:
		file_access = FileAccess.open("user://save_game.dat", FileAccess.READ)
	
	var file_contents : String = file_access.get_as_text()
	if file_contents == "" or file_contents == null :
		return FileAccess.get_open_error()
	
	var dict = JSON.parse_string(file_contents)
	print_debug(dict)
	if dict == null:
		return ERR_PARSE_ERROR
	
	_load_values_to_data_dict(dict)
	return OK

func save_to_file(encrypted:bool=false) -> Error:
	var json_string = JSON.stringify(data, "\t")
	var file_access : FileAccess
	if encrypted:
		file_access = FileAccess.open_encrypted_with_pass("user://save_game.dat", FileAccess.WRITE, encryption_key)
	else:
		file_access = FileAccess.open("user://save_game.dat", FileAccess.WRITE)
	if file_access == null:
		return FileAccess.get_open_error()
	
	file_access.store_string(json_string)
	return OK
