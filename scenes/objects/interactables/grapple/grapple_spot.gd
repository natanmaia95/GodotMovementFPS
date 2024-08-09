extends Node3D

@export var vertical_offset := 4.0
@export var grapple_speed := 17.0

func _ready():
	%InteractableComponent.interacted.connect(on_interacted)

func _process(_delta):
	%HighlightMesh.visible = (%InteractableComponent.hovering_characters.keys().size() != 0)

func on_interacted(source:Node3D):
	var character := source as CharacterBody3D
	if not character: return
	
	var direction = (global_position + Vector3.UP * vertical_offset) - character.global_position
	direction = direction.normalized()
	character.velocity = direction * grapple_speed
	print_debug("grapple")
