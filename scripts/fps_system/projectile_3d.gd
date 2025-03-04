@tool
class_name Projectile3D
extends CharacterBody3D

# movement
@export var INITIAL_SPEED : float = 5.0
@export var ACCELERATION : float = 0.0
@export var DRAG: float = 0.99

@export var can_have_negative_speed := false

var speed := 0.0
var last_frame_speed := 0.0

func _ready():
	if Engine.is_editor_hint(): 
		motion_mode = CharacterBody3D.MOTION_MODE_FLOATING
		return
	speed = INITIAL_SPEED

func _physics_process(delta):
	if Engine.is_editor_hint(): return
	
	speed += ACCELERATION * delta
	speed *= DRAG
	if speed < 0.0 and not can_have_negative_speed: speed = 0.0
	velocity = get_direction() * speed
	#velocity *= DRAG
	update(delta)
	move_and_collide(velocity * delta)

func set_direction(direction:Vector3) -> void:
	look_at(global_position + direction)
	velocity = get_direction() * speed

func get_direction() -> Vector3:
	return -global_basis.z

func update(_delta:float) -> void: pass
