class_name InventoryComponent
extends Node3D

signal selected_item_changed

@export var hitscan_component : HitscanComponent
@export var model_root : Node3D
var model : Node3D = null


#@export var HUD : Control
var items := []
var selected_index : int = -1 : set = _set_selected_index

var use_item_cooldown : float = 0.0
var was_item_used_this_frame := false

func _ready():
	_create_debug_weapons()



func _unhandled_input(event):
	#if event.is_action("fire") and event.is_pressed():
		#fire_item()
	#if event.is_action("alt_fire") and event.is_pressed():
		#alt_fire_item()
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			selected_index += 1
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			selected_index -= 1
	if event is InputEventKey and event.is_pressed():
		if event.keycode in range(49, 58): # 0 to 9 keys
			select(event.keycode - 49)


func _process(delta):
	use_item_cooldown -= delta
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_process_input(delta)



func _process_input(_delta):
	was_item_used_this_frame = false
	
	var item := get_selected_item()
	if item is FPSGun:
		if Input.is_action_pressed("fire") and item.can_fire():
			if Input.is_action_just_pressed("fire") and use_item_cooldown <= 0.0:
				fire_gun(item)
			elif item.can_auto_fire and use_item_cooldown <= -item.auto_fire_penalty:
				fire_gun(item)
	# TODO: other items?


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




func fire_gun(gun:FPSGun):
	assert(gun)
	hitscan_component.shoot(gun)
	model.play("shoot")
	AudioManager.play_sfx("vkproduktion_toygun.mp3")
	use_item_cooldown = gun.shot_cooldown
	#gun.current_ammo -= 1

func alt_fire_gun(gun:FPSGun):
	assert(gun)



func get_selected_item() -> FPSItem:
	if items.size() == 0: return null
	return items[selected_index]




func _set_selected_index(new_value) -> void:
	#if selected_index == new_value: return
	if items.size() == 0:
		selected_index = -1
	else:
		selected_index = wrapi(new_value, 0, items.size())
	if get_selected_item():
		if model: model.queue_free()
		model = get_selected_item().model_scene.instantiate()
		model_root.add_child(model)
		model.play("swap")
	
	selected_item_changed.emit()


func _create_debug_weapons() -> void:
	var pistol = load("res://resources/guns/gun_pistol.tres")
	var revolver = load("res://resources/guns/gun_revolver.tres")
	add_item(pistol)
	add_item(revolver)
