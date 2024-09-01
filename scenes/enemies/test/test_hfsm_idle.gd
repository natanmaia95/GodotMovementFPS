extends EntityHFSM

@onready var timer : float = 1.0
var rotate_tween : Tween = null
#these are the functions you might to redefine to create a custom logic:

# check_transition is the transition logic for transitioning on the same level as current node
func check_transition(_delta) -> HFSMTransitionData:
	return HFSMTransitionData.new(false, "")


# choose_internal_move is the function that is being called exactly one time on_enter of HFSM
# which is also a container. Return the state in which this sub state machine starts
func choose_internal_move() -> HFSMTransitionData:
	return HFSMTransitionData.new(false, "")


# update(delta) is the function that will be called every _physics_update(), put your logic here
func update(delta):
	timer -= delta
	if timer <= 0:
		timer = randf_range(1.0, 3.0)
		rotate_tween = create_tween()
		rotate_tween.tween_property(character, "rotation:y", randf()*2*PI, 0.5)

# if you need, create custom events with on_enter() and on_exit()
# these functions are called when the state starts or ends it's lifecycle
func on_enter():
	pass

func on_exit():
	rotate_tween.stop()
	pass

