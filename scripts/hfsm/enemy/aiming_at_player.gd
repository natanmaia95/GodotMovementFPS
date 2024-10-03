extends EntityHFSM


## [degrees per second] How fast the enemy aligns towards the player.
@export var tracking_speed := 120
@export var wait_before_shooting := 2.0
var actual_wait_before_shooting := 2.0

func choose_internal_move() -> HFSMTransitionData:
	return HFSMTransitionData.empty()

func check_transition(_delta) -> HFSMTransitionData:
	if get_progress() >= actual_wait_before_shooting:
		# needs aim to at least be kinda close
		var direction = direction_to_player()
		direction = Vector3(direction.x, 0, direction.z).normalized()
		if direction.dot(-character.global_basis.z) > 0.9: # 20° or less towards player
			return HFSMTransitionData.new(true, "shoot")
	return HFSMTransitionData.empty()

func on_enter():
	actual_wait_before_shooting = wait_before_shooting * randf_range(1.0, 1.5)
	pass

func update(delta):
	update_tracking(delta)

func update_tracking(delta):
	var enemy_to_player := direction_to_player()
	var hor_to_player := Vector2(enemy_to_player.z, -enemy_to_player.x)
	var enemy_facing := -character.global_basis.z
	var hor_facing := Vector2(enemy_facing.z, -enemy_facing.x)
	var new_angle = rotate_toward(hor_facing.angle(), hor_to_player.angle(), delta * deg_to_rad(tracking_speed))
	#var new_facing := Vector2.from_angle(new_angle)
	character.global_rotation.y = -new_angle + PI
