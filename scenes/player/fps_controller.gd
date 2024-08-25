class_name FPSController
extends CharacterBody3D


@export var look_sensitivity : float = 0.006
@export var auto_bhop_enabled := true
@export var tilt_enabled := true
@export var headbob_enabled := true
@export var toggle_crouch_enabled := false
#@export var toggle_sprint_enabled := false

@export var gravity := 16.0
@export var mass := 80.0 # for colliions with rbs

# "tried and tested" values
@export var jump_velocity := 6.0
@export var walk_speed := 10.0
#@export var sprint_speed := 11.0
@export var ground_accel := 8.0
@export var ground_decel := 20.0
@export var ground_friction := 2.0
@export var air_accel := 8.0
@export var max_controlled_air_speed := 5.0
@export var slide_base_speed := 12.0
@export var slide_minimum_speed := 3.0
@export var slide_bonus_speed_mult := 0.30
@export var slide_bonus_jump_speed := 3.0
@export var slide_speed_duration := 0.7
@export var wallrun_minimum_height := 1.0
@export var wallrun_fall_friction := 8.0
@export var wallrun_jump_velocity := 4.0
@export var wallrun_sidejump_velocity := 6.0
@export var wallrun_entryspeed_multiplyer := 1.15
@export var vault_max_height := 1.01
@export var vault_time := 0.2
@export var vault_window := 0.4
#@export var air_cap := 0.85
#@export var air_accel := 800.0
#@export var air_move_speed := 500.0

@export var max_fall_height_immune := 3.0

var input_direction := Vector2.ZERO
var wish_direction := Vector3.ZERO # input direction but in worldspace
var last_mouse_move := Vector2.ZERO

const HEADBOB_MOVE_AMOUNT = 0.02
const HEADBOB_FREQUENCY = 2.4
var headbob_timer := 0.0

const CROUCH_TRANSLATE := 0.7
const CROUCH_JUMP_ADD := 0.6 # jerks the camera up like Source
var is_crouching := false

var was_on_floor_last_frame := false
var is_sprinting := false
var is_wallrunning := false
var is_sliding := false
var slide_timer := 0.0

var is_in_turnaround := false
var turnaround_timer := 0.0
var is_vaulting := false
var jump_starting_height := -1000.0

var noclip_speed_mult := 10.0

var noclip_enabled := false : 
	set(value):
		noclip_enabled = value
		noclip_speed_mult = 10.0
		$CollisionShape3D.disabled = noclip_enabled
		# TODO: popup




func _ready():
	_ready_hide_model_for_camera()
	%InteractShapeCast.add_exception(self)
	%InventoryComponent.select(0)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass


func _ready_hide_model_for_camera():
	for child in %Model.find_children("*", "VisualInstance3D"):
		child.set_layer_mask_value(1, false)
		child.set_layer_mask_value(2, true)




func _unhandled_input(event):
	if Utils.is_mouse_captured():
		# camera
		if event is InputEventMouseMotion:
			last_mouse_move = Vector2(event.relative)
		
		# noclip
		if Input.is_action_just_pressed("noclip"):
			noclip_enabled = !noclip_enabled
		if event is InputEventMouseButton and event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				noclip_speed_mult = min(1000.0, noclip_speed_mult * 1.2)
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				noclip_speed_mult = max(.1, noclip_speed_mult * 1/1.2)
	
	
	# UI elements capture the mouse themselves to handle their input, which does not trigger this unhandled input call
	# If there's a click not handled by any UI this controller captures it, and if captured it controls fine
	# so the camera doesn't jerk while the player uses a menu.
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)





func _physics_process(delta) -> void:	
	if Utils.is_mouse_captured():
		input_direction = Input.get_vector("strafe_left", "strafe_right", "move_forward", "move_backward").normalized()
	else:
		input_direction = Vector2.ZERO
	wish_direction = self.global_basis * Vector3(input_direction.x, 0, input_direction.y)
	#_handle_ground_physics(delta)
	
	
	_handle_crouch(delta)
	
	if noclip_enabled:
		_handle_noclip(delta)
		return
	
	_handle_turnaround(delta)
	_handle_vaulting(delta)
	if is_on_floor():
		_handle_sprinting(delta)
		_handle_ground_physics(delta)
	else:
		_handle_wallclimb(delta)
		_handle_wallrun(delta)
		_handle_air_physics(delta)
	
	was_on_floor_last_frame = is_on_floor()
	_push_rigidbodies(delta)
	move_and_slide()
	
	if is_on_floor():
		_handle_landing()


func _handle_noclip(_delta) -> void:
	if not noclip_enabled: return
	
	var speed : float = noclip_speed_mult
	if Input.is_action_pressed("sprint"): speed *= 3.0
	
	var cam_aligned_wish_dir : Vector3 = %HeadCamera.global_basis * Vector3(input_direction.x, 0, input_direction.y)
	velocity = speed * cam_aligned_wish_dir
	move_and_slide()


func _handle_ground_physics(delta) -> void:
	is_wallrunning = false
	jump_starting_height = global_position.y
	
	#if not is_sliding:
	var cur_speed_in_wish_dir = velocity.dot(wish_direction)
	if is_sliding: cur_speed_in_wish_dir =  velocity.dot(-global_basis.z)
	#var capped_speed = min((air_move_speed * wish_direction).length(), air_cap)
	var add_speed_till_cap = get_move_speed() - cur_speed_in_wish_dir
	if add_speed_till_cap > 0:
		var accel_speed = ground_accel * get_move_speed() * delta
		accel_speed = min(accel_speed, add_speed_till_cap)
		#if not is_crouching or (is_crouching and velocity.length() < get_move_speed()):
		if is_sliding:
			velocity += accel_speed * -global_basis.z
		else:
			velocity += accel_speed * wish_direction
	
	#friction
	var current_speed = velocity.length()
	var control = max(current_speed, ground_decel)
	var drop = control * ground_friction * delta
	if is_sliding and slide_timer > 0.0:# and current_speed > get_move_speed():
		drop *= 0.1
	elif is_crouching and current_speed < get_move_speed()*1.1:
		drop *= 0.5
	elif is_sprinting and current_speed > get_move_speed()*1.1:
		drop *= 0.5
	var new_speed = max(current_speed - drop, 0)
	if current_speed > 0:
		new_speed /= current_speed
	velocity *= new_speed
	
	
	var final_jump_velocity = jump_velocity
	if is_sliding: 
		final_jump_velocity += slide_bonus_jump_speed
	if auto_bhop_enabled and Input.is_action_pressed("jump"):
		velocity.y += final_jump_velocity
	elif Input.is_action_just_pressed("jump"):
		velocity.y += final_jump_velocity



func _handle_air_physics(delta):
	is_sliding = false
	is_sprinting = false
	velocity.y -= gravity * delta # gravity
	# air redirection
	if wish_direction != Vector3.ZERO and not is_on_wall():
		if get_horizontal_velocity().length() > max_controlled_air_speed:
			velocity -= get_horizontal_velocity().normalized() * air_accel * delta
		velocity += wish_direction * air_accel * delta
	# save for fall damage
	if velocity.y > 0:
		jump_starting_height = global_position.y


func _handle_turnaround(delta):
	turnaround_timer -= delta
	if turnaround_timer <= 0 and Input.is_action_just_pressed("turnaround"):
		#velocity.x = 0
		#velocity.z = 0
		turnaround_timer = 0.8
		var turn_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		turn_tween.tween_property(self, "is_in_turnaround", true, 0.01)
		turn_tween.set_parallel(true)
		#turn_tween.tween_property(self, "velocity:x", 0, 0.3)
		#turn_tween.tween_property(self, "velocity:z", 0, 0.3)
		turn_tween.tween_property(self, "rotation:y", rotation.y + PI, 0.2) 
		turn_tween.set_parallel(false)
		turn_tween.tween_property(self, "is_in_turnaround", false, 0.01)


func _handle_vaulting(_delta):
	# skip if already vaulting; you also need to be sprinting to initiate
	#if is_vaulting or not is_sprinting: return
	if is_vaulting: return
	#if not Input.is_action_pressed("jump"): return
	# only start vault if looking approx. towards the running direction
	if (-global_basis.z).dot(get_horizontal_velocity()) < -0.1: return
	
	#%VaultRayCast.target_position = Vector3.FORWARD
	#%VaultRayCast.force_raycast_update()
	#if not %VaultRayCast.is_colliding(): return
	# first check if there's a wall in the future
	# then if the player can stand above that wall
	var prediction_speed = max(get_horizontal_velocity().length(), walk_speed)
	var movement_forwards = get_horizontal_velocity().normalized() * prediction_speed * 0.2
	#%VaultRayCast.target_position = Vector3.FORWARD * prediction_speed
	%VaultRayCast.target_position =  movement_forwards * global_basis
	%VaultRayCast.force_raycast_update()
	if not %VaultRayCast.is_colliding(): return
	var has_wall_in_front := test_move(global_transform, movement_forwards)
	if not has_wall_in_front: return
	var movement_climb = Vector3.UP * vault_max_height
	var can_stand_above := test_move(global_transform, movement_climb + movement_forwards)
	if not can_stand_above: return
	# for test reasons lets just teleport the player up
	#global_position += movement_climb
	is_vaulting = true
	movement_climb += get_horizontal_velocity().normalized() * prediction_speed * 0.2
	#var final_velocity = -global_basis.z * prediction_speed
	var final_velocity = get_horizontal_velocity().normalized() * prediction_speed
	final_velocity += Vector3.DOWN * 5.0 #fall faster
	var vault_tween = create_tween().set_ease(Tween.EASE_OUT)#.set_trans(Tween.TRANS_CUBIC)
	vault_tween.set_parallel(true)
	vault_tween.tween_property(self, "velocity", final_velocity, vault_time)
	vault_tween.tween_property(self, "global_position", global_position + movement_climb, vault_time)
	vault_tween.set_parallel(false)
	vault_tween.tween_callback(_handle_vaulting_stop)
	vault_tween.tween_property(self, "is_vaulting", false, 0.01)
	#pass

func _handle_vaulting_stop():
	if wish_direction == Vector3.ZERO:
		velocity.x = 0
		velocity.z = 0


func _handle_sprinting(_delta):
	is_sprinting = get_horizontal_velocity().length() >= 0.8 * walk_speed

@onready var _original_capsule_height = $CollisionShape3D.shape.height
func _handle_crouch(delta):
	var crouching_last_frame = is_crouching
	
	if is_sliding:
		is_crouching = true
	elif Utils.is_mouse_captured() and Input.is_action_pressed("crouch"):
		is_crouching = true
	else:
		if not test_move(global_transform, Vector3(0,CROUCH_TRANSLATE,0)):
			is_crouching = false
	
	#offset from jumping and crouching
	var crouchjump_y_translation := 0.0
	if crouching_last_frame != is_crouching and not is_on_floor():
		crouchjump_y_translation = CROUCH_TRANSLATE
		if not is_crouching:
			crouchjump_y_translation *= -1
		# test if can do the crouch jump thing
		if crouchjump_y_translation != 0.0:
			var result := KinematicCollision3D.new()
			test_move(global_transform, Vector3(0, crouchjump_y_translation, 0), result)
			position.y += result.get_travel().y
			%Head.position.y += result.get_travel().y * -CROUCH_JUMP_ADD
			#create_tween().tween_property(self,"position:y", position.y + result.get_travel().y, 0.2)
	
	#slide stuff
	if is_sliding:
		slide_timer -= delta
		if slide_timer <= 0: 
			is_sliding = false
		if get_horizontal_velocity().length() < slide_minimum_speed: 
			is_sliding = false
	
	var started_sliding := false
	if is_crouching and not crouching_last_frame and is_sprinting: started_sliding = true
	if is_crouching and not was_on_floor_last_frame and is_on_floor(): started_sliding = true
	if started_sliding:
		is_sliding = true
		slide_timer = slide_speed_duration
		var slide_speed = max(get_horizontal_velocity().length(), slide_base_speed)
		slide_speed *= (1 + slide_bonus_speed_mult)
		velocity -= get_horizontal_velocity()
		#velocity += global_basis * Vector3.FORWARD * slide_speed
		velocity += wish_direction * slide_speed
	
	var target_head_position = 0.0
	if is_crouching: target_head_position = -CROUCH_TRANSLATE
	if is_sliding: target_head_position = -CROUCH_TRANSLATE -0.4
	
	%Head.position = lerp(%Head.position, Vector3(0,target_head_position, 0), delta*10)
	%CollisionShape3D.shape.height = _original_capsule_height + (-CROUCH_TRANSLATE if is_crouching else 0.0)
	%CollisionShape3D.position.y = %CollisionShape3D.shape.height / 2
	
	


func _handle_wallclimb(_delta):
	return
	#if is_on_wall() and not is_on_ceiling():
		#velocity = -global_basis.z * 1
		#velocity.y = 5
		#velocity += -global_basis.z * walk_speed * delta


func _handle_wallrun(delta):
	if is_vaulting or is_crouching or is_on_floor() or not is_on_wall_only():
		is_wallrunning = false
		return
	# test minimum height for wallrun
	var is_near_ground = test_move(global_transform, Vector3.DOWN * wallrun_minimum_height)
	if not is_wallrunning and is_near_ground:
		return # dont start wallrunning, but end wallrunning fine 
	
	# if is_on_wall_only():
	var was_wallrunning_last_frame = is_wallrunning
	var wall_normal = get_wall_normal()
	# TODO: check if not facing the wall
	is_wallrunning = true
	# move player forwards
	var wall_forwards = Vector3.UP.cross(wall_normal)
	if not is_wall_to_the_left(): wall_forwards *= -1
	
	var speed = get_horizontal_velocity().length()
	var wall_hor_velocity = wall_forwards * speed
	# TODO: better friction formula
	# undo and redo gravity
	var wall_fall_speed = velocity.y
	if velocity.y < 0:
		wall_fall_speed = velocity.y * (1 - wallrun_fall_friction*delta) 
	if is_wallrunning and not was_wallrunning_last_frame:
		wall_fall_speed = max(wall_fall_speed + 2.0, 4.0)
		wall_hor_velocity *= wallrun_entryspeed_multiplyer
	
	velocity = Vector3(wall_hor_velocity.x, wall_fall_speed, wall_hor_velocity.z)
	
	if Input.is_action_just_pressed("jump"):
		velocity.y = wallrun_jump_velocity
		velocity += wall_normal * wallrun_sidejump_velocity


func _handle_landing():
	if not is_crouching:
		if global_position.y < jump_starting_height - max_fall_height_immune - 0.1:
			jump_starting_height = global_position.y
			velocity = Vector3(0,4,0)
			# TODO: damage, rolling


# majikayo games
func _push_rigidbodies(_delta):
	for i in get_slide_collision_count():
		var c := get_slide_collision(i)
		if c.get_collider() is RigidBody3D:
			var push_dir = -c.get_normal()
			var velocity_diff_push_dir = velocity.dot(push_dir) - c.get_collider().linear_velocity.dot(push_dir)
			velocity_diff_push_dir = max(0, velocity_diff_push_dir)
			var mass_ratio = min(1, mass / c.get_collider().mass)
			#dont push object from above or below
			push_dir.y = 0
			var push_force = mass_ratio * 5#magic number ooo
			c.get_collider().apply_impulse(push_dir*velocity_diff_push_dir*push_force, c.get_position - c.get_collider().global_position)





func _process(delta):
	_process_look_tilt(delta)
	_process_headbob_effect(delta)
	_process_interact_ray(delta)


func _process_headbob_effect(delta):
	headbob_timer += delta * velocity.length()
	if headbob_timer > PI*1000:
		headbob_timer -= PI*1000
	
	var target_v_offset := 0.0
	var target_h_offset := 0.0
	if headbob_enabled:
		if not is_on_floor() or velocity.length() < 2.0 or is_sliding:
			headbob_timer = 0.0
			target_v_offset = 0.0
			target_h_offset = 0.0
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
		var target_tilt_degrees := 0.0
		var tilt_speed_degrees := 0.0
		var should_lerp = false
		var should_update_tilt = true

		if last_mouse_move.x != 0:
			tilt_speed_degrees = clamp(last_mouse_move.x, -50, 50) * 5
			target_tilt_degrees = -sign(last_mouse_move.x)
			
			if sign(last_mouse_move.x) == sign(%Head.rotation_degrees.z):
				tilt_speed_degrees *= 4
			if is_in_turnaround:
				tilt_speed_degrees *= -4 #immediately reverse
			
			if is_sprinting and is_on_floor() and velocity.length() > 6.0:
				target_tilt_degrees *= 45
			else:
				target_tilt_degrees = 0
			
		if is_wallrunning:
			should_lerp = true
			target_tilt_degrees = -1 if is_wall_to_the_left() else 1
			target_tilt_degrees *= 30
			tilt_speed_degrees = 50
		
		if should_update_tilt:
			if should_lerp:
				%Head.rotation_degrees.z = lerp(%Head.rotation_degrees.z, target_tilt_degrees, abs(tilt_speed_degrees*delta)/10)
			else:
				%Head.rotation_degrees.z = move_toward(%Head.rotation_degrees.z, target_tilt_degrees, abs(tilt_speed_degrees)*delta)
			%Head.rotation_degrees.z = lerp(%Head.rotation_degrees.z, 0.0, delta*2)
	
	last_mouse_move = Vector2.ZERO


func _process_interact_ray(_delta):
	var possible_interactable : InteractableComponent = get_interactable()
	if possible_interactable:
		possible_interactable.hover_cursor(self)
		if Utils.is_mouse_captured() and Input.is_action_just_pressed("interact"):
			possible_interactable.interact(self)
	
	var possible_grapplable := get_grapple_point()
	if possible_grapplable:
		possible_grapplable.hover_cursor(self)
		if Utils.is_mouse_captured() and Input.is_action_just_pressed("grapple"):
			possible_grapplable.interact(self)



func get_move_speed() -> float:
	if is_crouching:
		return walk_speed * 0.5
	#elif is_sprinting:
		#return sprint_speed
	else:
		return walk_speed

#func is_sprinting() -> bool:
	#return  Input.is_action_pressed("sprint") and not is_crouching

func get_horizontal_velocity() -> Vector3:
	return Vector3(velocity.x, 0, velocity.z)

func get_facing_direction() -> Vector3:
	return -global_basis.z

func get_interactable() -> InteractableComponent:
	for index in %InteractShapeCast.get_collision_count():
		var collider = %InteractShapeCast.get_collider(index)
		if collider is InteractableComponent:
			if not collider.can_hover(self): continue
			return collider
	return null

func get_grapple_point() -> InteractableComponent:
	for index in %GrappleShapeCast.get_collision_count():
		var collider = %GrappleShapeCast.get_collider(index)
		if collider is InteractableComponent:
			if not collider.can_hover(self): continue
			return collider
	return null

func is_wall_to_the_left():
	if not is_on_wall():
		return false
	var cross = (-global_basis.z).cross(get_wall_normal())
	return cross.y < 0.0

