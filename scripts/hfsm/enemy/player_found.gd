extends EntityHFSM



## How far the player needs to be to get away from this enemy's vision.
## Doesn't check for LOS. Don't make this smaller than the detection range for Not Found state.
@export var detection_loss_range := 64.0


func choose_internal_move() -> HFSMTransitionData:
	return HFSMTransitionData.new(true, "alerted") # small alert animation

func check_transition(_delta) -> HFSMTransitionData:
	# todo: check if running every frame is good or bad
	if not can_see_player():
		HFSMTransitionData.new(true, "player_not_found")
	return HFSMTransitionData.empty()

func can_see_player() -> bool:
	if not player: return false
	return (player.global_position - character.global_position).length() > detection_loss_range

func update(delta) -> void:
	pass
