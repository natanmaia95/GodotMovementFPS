extends EntityHFSM



func check_transition(_delta) -> HFSMTransitionData:
	return HFSMTransitionData.new(false, "as we are top layer single state, we never transition")

# choose_internal_move is the function that is being called exactly one time on_enter of HFSM
# which is also a container. Return the state in which this sub state machine starts
func choose_internal_move() -> HFSMTransitionData:
	return HFSMTransitionData.new(true, "alive")

# update(delta) is the function that will be called every _physics_update(), put your logic here
func update(_delta):
	pass

# if you need, create custom events with on_enter() and on_exit()
# these functions are called when the state starts or ends it's lifecycle
func on_enter():
	pass

func on_exit():
	pass
