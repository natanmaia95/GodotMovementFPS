class_name InventoryComponent
extends Node3D

signal selected_item_changed

@export var hitscan_component : HitscanComponent

#@export var HUD : Control
var items := []
var selected_index : int = -1 : set = _set_selected_index


func _ready():
	_create_debug_weapons()



func _unhandled_input(event):
	if event is InputEventMouseButton and event.is_pressed():
		print(event)
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			selected_index += 1
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			selected_index -= 1


func add_item(item):
	items.push_back(item)
	if items.size() != 0:
		selected_index = 0


func remove_item(index):
	if items.size() == 0:
		printerr("removing items from an empty inventory?")
		return
	items.remove_at(index)
	selected_index -= 1


func drop(index):
	remove_item(index)
	pass


func select(index):
	selected_index = index


func get_selected_item():
	if items.size() == 0: return null
	return items[selected_index]




func _set_selected_index(new_value) -> void:
	#if selected_index == new_value: return
	if items.size() == 0:
		selected_index = -1
	else:
		selected_index = wrapi(new_value, 0, items.size())
	selected_item_changed.emit()


func _create_debug_weapons() -> void:
	var pistol = FPSGun.new()
	pistol.item_name = "Pistol"
	pistol.damage = 10.0
	pistol.max_range = 64.0
	pistol.deviation = Vector2.ONE * 1
	var shotgun = FPSGun.new()
	shotgun.item_name = "Shotgun"
	shotgun.damage = 50.0
	shotgun.max_range = 16.0
	shotgun.deviation = Vector2.ONE * 5
	add_item(pistol)
	add_item(shotgun)
