extends EntityHFSM


## This move will always be selected as default alive state.
@export var starting_move_name : String = ""

## If true, transition to Dead, which deletes.
## Else, transition to custom "Defeated" state.
@export var can_die := true

var is_health_depleted := false


func check_transition(_delta) -> HFSMTransitionData:
	if is_health_depleted: 
		if can_die: return HFSMTransitionData.new(true, "dead")
		else: return HFSMTransitionData.new(true, "defeated")
	
	return HFSMTransitionData.empty()


func on_health_depleted() -> void:
	is_health_depleted = true


func choose_internal_move() -> HFSMTransitionData:
	return HFSMTransitionData.new(true, starting_move_name)
