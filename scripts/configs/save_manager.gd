extends Node

var data = {}

func _ready():
	setup_default_data()
	var err = load_data()
	set_data("records/total_score", 2300)
	save_data()

func load_data():
	load_from_json()
	pass

func save_data():
	save_to_json()
	pass

## Please inst_to_dict your values first.
func set_data(key:String, value) -> void:
	assert(not value is Object)
	_set_data(key, value)

func get_data(key:String):
	return _get_data(key)


func _set_data(key:String, value, dict=data) -> void:
	var split_key = key.split("/", false, 1)
	print_debug(split_key)
	if split_key.size() == 1:
		dict[key] = value
		return
	else:
		dict[split_key[0]] = {}
		_set_data(split_key[1], value, dict[split_key[0]])
		return

func _get_data(key:String, dict=data):
	var split_key = key.split("/", false, 1)
	print_debug(split_key)
	if not dict.has(split_key[0]): 
		return null
	elif split_key.size() == 1:
		return dict[split_key[0]]
	else:
		var result = _get_data(split_key[1], dict[split_key[0]])
		if result == null and dict == data:
			printerr("Couldn't find data at key: '%s'" % key)
		return result

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
	return OK

func save_to_json() -> Error:
	var json_string = JSON.stringify(data, "\t")
	var file_access = FileAccess.open("user://save_game.json", FileAccess.WRITE)
	file_access.store_string(json_string)	
	return OK
