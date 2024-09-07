extends EntityHFSM

#var packed_bullet = preload("res://scenes/enemies/test/test_enemy_1_bullet.tscn")
@export var packed_bullet : PackedScene = null

@export var shoot_delay := 0.1
@export var shoot_total_duration := 0.5
@export var shoot_height_offset := 1.3

var has_shot := false

# to set up anything inside the state, before it is entered
func ready(): 
	pass

# choose_internal_move is the function that is being called exactly one time on_enter of HFSM
# which is also a container. Return the state in which this sub state machine starts
func choose_internal_move() -> HFSMTransitionData:
	return HFSMTransitionData.empty()

# check_transition is the transition logic for transitioning on the same level as current node
func check_transition(_delta) -> HFSMTransitionData:
	if get_progress() >= shoot_total_duration:
		return HFSMTransitionData.new(true, "aiming_at_player")
	return HFSMTransitionData.empty()

# update(delta) is the function that will be called every _physics_update(), put your logic here
func update(_delta):
	if not has_shot and get_progress() > shoot_delay:
		shoot()

# if you need, create custom events with on_enter() and on_exit()
# these functions are called when the state starts or ends it's lifecycle
func on_enter():
	has_shot = false
	pass

func shoot() -> void:
	has_shot = true
	var direction := direction_to_player()
	var forwards := -character.global_basis.z
	direction = Vector3(forwards.x, direction.y, forwards.z).normalized()
	var bullet_instance = packed_bullet.instantiate()
	character.get_tree().current_scene.add_child(bullet_instance)
	bullet_instance.global_position = character.global_position + Vector3.UP*shoot_height_offset
	bullet_instance.set_direction(direction)
	
