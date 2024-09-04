extends Node3D

@export var vertical_offset := 4.0
@export var grapple_speed := 14.0
@export var cooldown := 1.0

@export var disabled := false:
	set(value):
		disabled = value
		if disabled: disabled_timer = cooldown
		on_set_disabled()

var disabled_timer := 0.0

func _ready():
	%InteractableComponent.interacted.connect(on_interacted)
	%InteractableComponent.collision_layer = 0 + int(pow(2, FPSDefs.PhysicsLayers.GRAPPLE-1))

func _process(_delta):
	%HighlightMesh.visible = (not disabled) and (%InteractableComponent.hovering_characters.keys().size() != 0)

func _physics_process(delta):
	if disabled_timer > 0.0:
		disabled_timer -= delta
		if disabled_timer <= 0:
			disabled = false

func on_interacted(source:Node3D):
	if disabled: return
	var character := source as CharacterBody3D
	if not character: return
	
	var direction = (global_position + Vector3.UP * vertical_offset) - character.global_position
	direction = direction.normalized()
	character.velocity = direction * grapple_speed
	# prevent gravity for half a second
	var tween = create_tween()
	tween.tween_property(character, "velocity:y", character.velocity.y, 0.3)
	ScoreManager.push_action("player_grapple")
	disabled = true
	#print_debug("grapple")

func on_set_disabled() -> void:# pass
	%BaseMesh.visible = not disabled
