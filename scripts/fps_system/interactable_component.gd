@tool
class_name InteractableComponent
extends Area3D

signal interacted(source:Node3D)

var hovering_characters : Dictionary = {}

func _ready():
	if Engine.is_editor_hint():
		_setup_collisions()

func interact(source:Node3D = null) -> void:
	interacted.emit(source)

func hover_cursor(character:Node3D) -> void:
	hovering_characters[character] = Engine.get_process_frames()#adds a time count

func can_hover(character:Node3D) -> bool:
	return true

func get_character_hovering_current_camera() -> Node3D:
	for character in hovering_characters.keys():
		var current_camera : Camera3D = null
		if get_viewport(): current_camera = get_viewport().get_camera_3d()
		if not current_camera: continue
		if current_camera.owner == character:
			return character
		
	return null

func _process(_delta):
	for character in hovering_characters.keys():
		if Engine.get_process_frames() - hovering_characters[character] > 1:
			hovering_characters.erase(character)

func _setup_collisions():
	collision_layer = 0 + int(pow(2, FPSDefs.PhysicsLayers.INTERACTABLE-1))
	collision_mask = 0
