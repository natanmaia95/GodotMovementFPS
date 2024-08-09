extends Node
## Utils.gd
## Useful functions for all sorts of places.

func is_mouse_captured() -> bool:
	return Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED

func get_all_file_paths(path: String) -> Array[String]:
	var file_paths: Array[String] = []
	var dir = DirAccess.open(path)
	if dir == null:
		push_error("Path \"", path, "\" doesn't exist.")
		return []
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		var file_path = path + "/" + file_name # global path separator, includes Windows
		file_paths.append(file_path)
		file_name = dir.get_next()
	return file_paths
