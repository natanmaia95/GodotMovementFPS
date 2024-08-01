extends CharacterBody3D


@export var look_sensitivity : float = 0.006
@export var jump_velocity := 6.0
@export var auto_bhop_enabled := true
@export var tilt_enabled := true

@export var gravity := 16.0
@export var air_accel := 10.0

# "tried and tested" values

@export var walk_speed := 7.0
@export var sprint_speed := 11.0
@export var ground_accel := 14.0
@export var ground_decel := 10.0
@export var ground_friction := 6.0
@export var air_cap := 0.85
#@export var air_accel := 800.0
@export var air_move_speed := 500.0

const HEADBOB_MOVE_AMOUNT = 0.1
const HEADBOB_FREQUENCY = 2.4
var headbob_timer := 0.0

var input_direction := Vector2.ZERO
var wish_direction := Vector3.ZERO # input direction but in worldspace
var last_mouse_move := Vector2.ZERO
var look_tilt_timer := 0.0
var is_in_turnaround := false
var turnaround_timer := 0.0

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
			last_mouse_move = Vector2(event.relative)




func _physics_process(delta):
	input_direction = Input.get_vector("strafe_left", "strafe_right", "move_forward", "move_backward").normalized()
	wish_direction = self.global_transform.basis * Vector3(input_direction.x, 0, input_direction.y)
	#_handle_ground_physics(delta)
	if is_on_floor():
		_handle_turnaround(delta)
		_handle_ground_physics(delta)
	else:
		_handle_air_physics(delta)
		_handle_wallclimb(delta)
	
	move_and_slide()


func _handle_ground_physics(delta):
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
	
	if auto_bhop_enabled and Input.is_action_pressed("jump"):
		velocity.y += jump_velocity
	elif Input.is_action_just_pressed("jump"):
		velocity.y += jump_velocity


func _handle_air_physics(delta):
	velocity.y -= gravity * delta # gravity
	
	# air braking
	#var hor_velocity = Vector3(velocity.x, 0, velocity.z)
	#if Input.is_action_pressed("move_backward"):
		#velocity -= hor_velocity * delta *1
	
	# source/quake air movement
	#var speed_projected_to_wish_direction = velocity.dot(wish_direction)
	#var capped_speed = min((air_move_speed * wish_direction).length(), air_cap)
	#var speed_remaining_until_cap = capped_speed - speed_projected_to_wish_direction
	#if speed_remaining_until_cap > 0:
		#var accel_speed = air_accel * air_move_speed * delta
		#accel_speed = min(accel_speed, speed_remaining_until_cap)
		#velocity += accel_speed * wish_direction
	
	#var cur_speed_in_wish_dir = self.velocity.dot(wish_direction)
	#var capped_speed = min((air_move_speed * wish_direction).length(), air_cap)
	#var add_speed_till_cap = capped_speed - cur_speed_in_wish_dir
	#if add_speed_till_cap > 0:
		#var accel_speed = air_accel * air_move_speed * delta
		#accel_speed = min(accel_speed, add_speed_till_cap)
		#velocity += accel_speed * wish_direction


func _handle_turnaround(delta):
	turnaround_timer -= delta
	if turnaround_timer <= 0 and Input.is_action_just_pressed("turnaround"):
		velocity.x = 0
		velocity.z = 0
		turnaround_timer = 0.8
		var turn_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		turn_tween.tween_property(self, "is_in_turnaround", true, 0.01)
		turn_tween.set_parallel(true)
		turn_tween.tween_property(self, "velocity:x", 0, 0.3)
		turn_tween.tween_property(self, "velocity:z", 0, 0.3)
		turn_tween.tween_property(self, "rotation:y", rotation.y + PI, 0.4) 
		turn_tween.set_parallel(false)
		turn_tween.tween_property(self, "is_in_turnaround", false, 0.01)


func _handle_wallclimb(delta):
	if is_on_wall() and not is_on_ceiling():
		velocity = -global_basis.z * 1
		velocity.y = 5
		#velocity += -global_basis.z * walk_speed * delta

func _process(delta):
	
	
	_process_look_tilt(delta)
	if is_on_floor():
		_process_headbob_effect(delta)
		


func _process_headbob_effect(delta):
	headbob_timer += delta * velocity.length()
	if headbob_timer > PI*1000:
		headbob_timer -= PI*1000
	
	var target_v_offset := 0.0
	var target_h_offset := 0.0
	if velocity.length() < 2.0:
		headbob_timer = 0
		target_v_offset = 0
		target_h_offset = 0
	else:
		target_v_offset = HEADBOB_MOVE_AMOUNT * sin(headbob_timer * PI*2 / HEADBOB_FREQUENCY)
		target_h_offset = HEADBOB_MOVE_AMOUNT * 0.5 * sin(0.5 * headbob_timer * PI*2 / HEADBOB_FREQUENCY)
	
	%HeadCamera.v_offset = move_toward(%HeadCamera.v_offset, target_v_offset, delta*1)
	%HeadCamera.h_offset = move_toward(%HeadCamera.h_offset, target_h_offset, delta*1)


func _process_look_tilt(delta):
	# look
	rotate_y(-last_mouse_move.x * look_sensitivity)
	%HeadCamera.rotate_x(-last_mouse_move.y * look_sensitivity)
	%HeadCamera.rotation.x = clamp(%HeadCamera.rotation.x, -PI*0.3, PI*0.3)
	
	# tilt
	if tilt_enabled:
		look_tilt_timer += delta
		var target_tilt_degrees := 0.0
		var tilt_speed_degrees := 0.0
		var should_lerp = false
		var should_update_tilt = true
		if !is_on_floor():
			#should_lerp = true
			tilt_speed_degrees = 100
		else:
			if last_mouse_move.x != 0:
				look_tilt_timer = 0.0
				tilt_speed_degrees = clamp(last_mouse_move.x, -50, 50) * 5
				#print(tilt_speed_degrees)
				target_tilt_degrees = -sign(last_mouse_move.x)
				target_tilt_degrees *= 45 if is_sprinting() else 0
				
				if sign(last_mouse_move.x) == sign(%Head.rotation_degrees.z):
					tilt_speed_degrees *= 4
				if is_in_turnaround:
					tilt_speed_degrees *= -4
		
		if should_update_tilt:
			if should_lerp:
				%Head.rotation_degrees.z = lerp(%Head.rotation_degrees.z, target_tilt_degrees, abs(tilt_speed_degrees*delta)/10)
			else:
				%Head.rotation_degrees.z = move_toward(%Head.rotation_degrees.z, target_tilt_degrees, abs(tilt_speed_degrees)*delta)
			%Head.rotation_degrees.z = lerp(%Head.rotation_degrees.z, 0.0, delta*2)
	
	#if is_sprinting():
		#last_mouse_move = lerp(last_mouse_move, Vector2.ZERO, delta*10)
	#else:
	last_mouse_move = Vector2.ZERO
	#if abs(last_mouse_move.x) < 0.5 and abs(last_mouse_move.y) < 0.5:
		#last_mouse_move = Vector2.ZERO
	print(last_mouse_move)


func get_move_speed() -> float:
	return sprint_speed if is_sprinting() else walk_speed

func is_sprinting() -> bool:
	return  Input.is_action_pressed("sprint")
