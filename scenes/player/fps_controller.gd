extends CharacterBody3D


@export var look_sensitivity : float = 0.006
@export var jump_velocity := 6.0
@export var auto_bhop := true

@export var gravity := 16.0

# "tried and tested" values
@export var walk_speed := 7.0
@export var sprint_speed := 11.0
@export var ground_accel := 14.0
@export var ground_decel := 10.0
@export var ground_friction := 6.0
@export var air_cap := 0.85
@export var air_accel := 800.0
@export var air_move_speed := 500.0

const HEADBOB_MOVE_AMOUNT = 0.06
const HEADBOB_FREQUENCY = 2.4
var headbob_timer := 0.0

var input_direction := Vector2.ZERO
var wish_direction := Vector3.ZERO # input direction but in worldspace



func _ready():
	_ready_hide_model_for_camera()
	pass


func _ready_hide_model_for_camera():
	for child in %Model.find_children("*", "VisualInstance3D"):
		child.set_layer_mask_value(1, false)
		child.set_layer_mask_value(2, true)




func _unhandled_input(event):
	# UI elements capture the mouse themselves to handle their input, which does not trigger this unhandled input call
	# If there's a click not handled by any UI this controller captures it, and if captured it controls fine
	# so the camera doesn't jerk while the player uses a menu.
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			rotate_y(-event.relative.x * look_sensitivity)
			%HeadCamera.rotate_x(-event.relative.y * look_sensitivity)
			%HeadCamera.rotation.x = clamp(%HeadCamera.rotation.x, -PI/2, PI/2)




func _physics_process(delta):
	input_direction = Input.get_vector("strafe_left", "strafe_right", "move_forward", "move_backward").normalized()
	wish_direction = self.global_transform.basis * Vector3(input_direction.x, 0, input_direction.y)
	#_handle_ground_physics(delta)
	if is_on_floor():
		_handle_ground_physics(delta)
	else:
		_handle_air_physics(delta)
	
	move_and_slide()


func _handle_ground_physics(delta):
	#velocity = wish_direction * get_move_speed()
	
	var cur_speed_in_wish_dir = self.velocity.dot(wish_direction)
	#var capped_speed = min((air_move_speed * wish_direction).length(), air_cap)
	var add_speed_till_cap = get_move_speed() - cur_speed_in_wish_dir
	if add_speed_till_cap > 0:
		var accel_speed = ground_accel * get_move_speed() * delta
		accel_speed = min(accel_speed, add_speed_till_cap)
		velocity += accel_speed * wish_direction
	
	#friction
	var current_speed = velocity.length()
	var control = max(current_speed, ground_decel)
	var drop = control * ground_friction * delta
	var new_speed = max(current_speed - drop, 0)
	if current_speed > 0:
		new_speed /= current_speed
	velocity *= new_speed
	
	if auto_bhop and Input.is_action_pressed("jump"):
		velocity.y += jump_velocity
	elif Input.is_action_just_pressed("jump"):
		velocity.y += jump_velocity


func _handle_air_physics(delta):
	velocity.y -= gravity * delta # gravity
	
	# source/quake air movement
	#var speed_projected_to_wish_direction = velocity.dot(wish_direction)
	#var capped_speed = min((air_move_speed * wish_direction).length(), air_cap)
	#var speed_remaining_until_cap = capped_speed - speed_projected_to_wish_direction
	#if speed_remaining_until_cap > 0:
		#var accel_speed = air_accel * air_move_speed * delta
		#accel_speed = min(accel_speed, speed_remaining_until_cap)
		#velocity += accel_speed * wish_direction
	
	var cur_speed_in_wish_dir = self.velocity.dot(wish_direction)
	var capped_speed = min((air_move_speed * wish_direction).length(), air_cap)
	var add_speed_till_cap = capped_speed - cur_speed_in_wish_dir
	if add_speed_till_cap > 0:
		var accel_speed = air_accel * air_move_speed * delta
		accel_speed = min(accel_speed, add_speed_till_cap)
		velocity += accel_speed * wish_direction




func _process(delta):
	
	if is_on_floor():
		_process_headbob_effect(delta)


func _process_headbob_effect(delta):
	headbob_timer += delta * velocity.length()
	if headbob_timer > PI*1000:
		headbob_timer -= PI*1000
	%HeadCamera.v_offset = HEADBOB_MOVE_AMOUNT * sin(headbob_timer * HEADBOB_FREQUENCY / PI*2)
	%HeadCamera.h_offset = HEADBOB_MOVE_AMOUNT * sin(0.5 * headbob_timer * HEADBOB_FREQUENCY / PI*2 )




func get_move_speed() -> float:
	return sprint_speed if Input.is_action_pressed("sprint") else walk_speed
