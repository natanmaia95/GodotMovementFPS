class_name ConfigEntry
extends Resource
## Just virtual functions you should reimplement yourself for each config.

## We need some kind of object to interact with the scene tree. 
## Let's use the existing ConfigManager 
var manager : Node = null

func get_key() -> String:
	printerr("Entry with default function, override this function!",self)
	return ""

func get_section() -> String:
	printerr("Entry with default function, override this function!",self)
	return ""

func get_possible_values():
	printerr("Entry with default function, override this function!",self)

func get_default_value():
	printerr("Entry with default function, override this function!",self)

func on_changed(_new_value):
	printerr("Entry with default function, override this function!",self)
