extends Node3D

@export var vertical_offset := 4.0
@export var grapple_speed := 14.0

func _ready():
	%InteractableComponent.interacted.connect(on_interacted)
	%InteractableComponent.collision_layer = 0 + int(pow(2, FPSDefs.PhysicsLayers.GRAPPLE-1))

func _process(_delta):
	%HighlightMesh.visible = (%InteractableComponent.hovering_characters.keys().size() != 0)

func on_interacted(source:Node3D):
	var character := source as CharacterBody3D
	if not character: return
	
	var direction = (global_position + Vector3.UP * vertical_offset) - character.global_position
	direction = direction.normalized()
	character.velocity = direction * grapple_speed
	# prevent gravity for half a second
	var tween = create_tween()
	tween.tween_property(character, "velocity:y", character.velocity.y, 0.3)
	
	#print_debug("grapple")
