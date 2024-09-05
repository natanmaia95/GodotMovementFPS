extends EntityHFSM

func check_transition(_delta) -> HFSMTransitionData:
	return HFSMTransitionData.empty()

func choose_internal_move() -> HFSMTransitionData:
	return HFSMTransitionData.empty()

# update(delta) is the function that will be called every _physics_update(), put your logic here
func update(_delta):
	if close_to_end_of_animation():
		character.queue_free()

func on_enter():
	#print_debug("deado")
	ScoreManager.on_enemy_defeated(character)
