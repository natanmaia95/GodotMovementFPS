extends EntityHFSM


#these are the functions you might to redefine to create a custom logic:

# check_transition is the transition logic for transitioning on the same level as current node
func check_transition(_delta) -> HFSMTransitionData:
	return HFSMTransitionData.new(true, "to what")

# choose_internal_move is the function that is being called exactly one time on_enter of HFSM
# which is also a container. Return the state in which this sub state machine starts
func choose_internal_move() -> HFSMTransitionData:
	return HFSMTransitionData.new(true, "where to start")

# to set up anything inside the state, before it is entered
func ready() -> void: 
	pass

# update(delta) is the function that will be called every _physics_update(), put your logic here
func update(_delta):
	pass

# if you need, create custom events with on_enter() and on_exit()
# these functions are called when the state starts or ends it's lifecycle
func on_enter():
	pass

func on_exit():
	pass
