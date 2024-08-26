@tool
class_name HurtboxComponent
extends Area3D

signal damage_taken(amount)

@export var disabled := false:
	set(value):
		disabled = value
		set_deferred("monitoring", !value)
		set_deferred("monitorable", !value)
		set_deferred("process_mode", Node.PROCESS_MODE_DISABLED if disabled else PROCESS_MODE_INHERIT)

@export var is_player_hurtbox := false:
	set(value):
		is_player_hurtbox = value
		set_collision_layer_value(FPSDefs.PhysicsLayers.PLAYER_HURTBOX, value)
		set_collision_layer_value(FPSDefs.PhysicsLayers.ENEMY_HURTBOX, !value)

func _ready():
	if Engine.is_editor_hint():
		_setup_collisions()

func damage(amount):
	damage_taken.emit(amount)

#func _process(delta):
	#if Input.is_action_just_pressed("jump"):
		#damage(0)

func _setup_collisions():
	collision_layer = 0 + int(pow(2, FPSDefs.PhysicsLayers.HURTBOX-1))
	collision_mask = 0
