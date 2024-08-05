class_name HitscanComponent
extends Node3D

var hurtboxes_to_ignore := [] :
	set(value):
		hurtboxes_to_ignore = value
		print("list_changed")
		for item in hurtboxes_to_ignore: 
			ray.add_exception(item)

@onready var ray : RayCast3D = RayCast3D.new()

# TODO: get stats from weapons
@export var max_range : float = 30.0
@export var bullet_damage : float = 1000.0

@export var owner_hurtbox : HurtboxComponent

func _ready():
	if owner_hurtbox:
		hurtboxes_to_ignore.append(owner_hurtbox)
	setup_hitscan_raycast()
	add_child(ray)

func shoot() -> bool:
	#var ray := setup_hitscan_raycast()
	#var direction := -global_basis.z
	ray.target_position = Vector3.FORWARD * max_range
	
	# actually shoot the raycast
	ray.force_raycast_update()
	
	var collider = ray.get_collider()
	if collider:
		apply_damage_to_target(collider)
	
	return !!collider # true if not null, false if null

func setup_hitscan_raycast():
	for item in hurtboxes_to_ignore: 
		ray.add_exception(item)
	ray.target_position = Vector3.FORWARD * max_range
	ray.collide_with_areas = true
	ray.collide_with_bodies = false
	ray.collision_mask = 0
	ray.set_collision_mask_value(FPSDefs.PhysicsLayers.HURTBOX, true)
	ray.debug_shape_thickness = 2

func apply_damage_to_target(collider:Object) -> void:
	if collider is HurtboxComponent:
		var hurtbox := collider as HurtboxComponent
		hurtbox.damage(bullet_damage)
