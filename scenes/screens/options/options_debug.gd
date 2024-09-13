extends Control

var packed_selectable = preload("res://scenes/screens/options/ui/config_selectable.tscn")

func _ready():
	setup_list()

func setup_list():
	for entry in ConfigManager.entries.values():
		var selectable = packed_selectable.instantiate()
		%OptionsListVBox.add_child(selectable)
		selectable.build(entry)
		
