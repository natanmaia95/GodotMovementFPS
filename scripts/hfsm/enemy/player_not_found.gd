extends EntityHFSM

## How close the player needs to be to be detected even without line of sight.
## Currently, distance is calculated from feet position.
@export var close_detection_range := 4.0

## How close the player needs to be to be detected, given the enemy also has line of sight.
## Currently, LOS is calculated from feet position.
@export var long_detection_range := 16.0

@export var sight_cone_angle_degrees := 120.0

## This move will always be selected as default alive state.
@export var starting_move_name : String = ""


func choose_internal_move() -> HFSMTransitionData:
	return HFSMTransitionData.new(true, starting_move_name)

func check_transition(_delta) -> HFSMTransitionData:
	# todo: check if running every frame is good or bad
	if can_see_player():
		return HFSMTransitionData.new(true, "player_found")
	return HFSMTransitionData.empty()

func can_see_player() -> bool:
	if not player: return false
	
	var enemy_to_player : Vector3 = player.global_position - character.global_position
	var length = enemy_to_player.length()
	#print_debug("distance: ", length)
	# close detection
	if length <= close_detection_range: return true
	# long detection
	if length <= long_detection_range:
		var hor_direction = Vector3(enemy_to_player.x, 0, enemy_to_player.z).normalized()
		var angle_degrees = rad_to_deg(hor_direction.angle_to(-character.global_basis.z))
		#print_debug("angle: ", angle_degrees)
		if angle_degrees <= sight_cone_angle_degrees*0.5:
			return true
	return false
