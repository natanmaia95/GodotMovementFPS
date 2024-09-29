extends EntityHFSM

@export var hurtbox_component : HurtboxComponent

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
	character.collision_layer = 0
	character.collision_mask = 0
	if hurtbox_component:
		hurtbox_component.disabled = true
	ScoreManager.on_enemy_defeated(character)
