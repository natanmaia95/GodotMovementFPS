extends EntityHFSM


@export var next_move_name : String


# to set up anything inside the state, before it is entered
func ready(): 
	pass

# choose_internal_move is the function that is being called exactly one time on_enter of HFSM
# which is also a container. Return the state in which this sub state machine starts
func choose_internal_move() -> HFSMTransitionData:
	return HFSMTransitionData.empty()

# check_transition is the transition logic for transitioning on the same level as current node
func check_transition(_delta) -> HFSMTransitionData:
	if is_animation_finished():
		return HFSMTransitionData.new(true, next_move_name)
	return HFSMTransitionData.empty()

# update(delta) is the function that will be called every _physics_update(), put your logic here
func update(_delta):
	pass

# if you need, create custom events with on_enter() and on_exit()
# these functions are called when the state starts or ends it's lifecycle
func on_enter():
	pass

func on_exit():
	if animator: animator.play("RESET")
