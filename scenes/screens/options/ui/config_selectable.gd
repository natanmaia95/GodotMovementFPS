extends HBoxContainer

var entry : ConfigEntry = null
@onready var toggle : CheckButton = %Toggle
@onready var slider : HSlider = %Slider
@onready var list : OptionButton = %List

func _ready():
	#toggle.visible = false
	#slider.visible = false
	#list.visible = false
	#build(ConfigManager.entries["is_fullscreen"])
	pass

func build(entry_in:ConfigEntry) -> bool:
	if entry_in == null: return false
	if entry_in.get_option_type() == 0: return false
	entry = entry_in
	
	%OptionName.text = entry.get_key()
	match entry.get_option_type():
		ConfigEntry.OptionType.TOGGLE:
			build_toggle()
		ConfigEntry.OptionType.SLIDER:
			build_slider()
		ConfigEntry.OptionType.LIST:
			build_list()
	
	return true

func build_toggle() -> void:
	toggle.visible = true
	toggle.button_pressed = ConfigManager.get_config(entry.get_key())
	toggle.pressed.connect(on_toggle_pressed)

func build_slider() -> void:
	slider.visible = true
	var range = entry.get_possible_values()
	print_debug(range)
	if range is Array:
		slider.min_value = range[0]
		slider.max_value = range[1]
		slider.step = range[2]
	elif range is Range:
		print_debug("%f, %f, %f" % [range.min_value, range.max_value, range.step])
		slider.min_value = range.min_value
		slider.max_value = range.max_value
		slider.step = range.step
	else:
		printerr("Invalid possible value type for Slider Option; ", entry.get_key(), entry.get_possible_values())
	
	slider.value = ConfigManager.get_config(entry.get_key())
	slider.value_changed.connect(on_slider_value_changed)

func build_list() -> void:
	var values : Array = entry.get_possible_values()
	var current_value = ConfigManager.get_config(entry.get_key())
	list.visible = true
	for value in values:
		if value is String and value == "":
			list.add_separator()
		else:
			list.add_item(str(value))
		if value == current_value:
			list.select(list.item_count-1)
	list.item_selected.connect(on_list_item_selected)
	

func on_toggle_pressed() -> void:
	ConfigManager.set_config(entry.get_key(), toggle.button_pressed)

func on_slider_value_changed(new_value) -> void:
	ConfigManager.set_config(entry.get_key(), new_value)

func on_list_item_selected(index:int) -> void:
	var values : Array = entry.get_possible_values()
	var new_value = values[index]
	ConfigManager.set_config(entry.get_key(), new_value)
