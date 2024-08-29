extends EntityHFSM

func check_transition(_delta) -> HFSMTransitionData:
	return HFSMTransitionData.empty()

func choose_internal_move() -> HFSMTransitionData:
	return HFSMTransitionData.empty()

func on_enter():
	ScoreManager.on_enemy_defeated(character)
