class_name EntityHFSM
extends Node
#Based on Gab-ani's HFSM implementation.


# The global export fields section. You don't need to set them up for each state,
# do only for the top layer single state that contains the whole state machine.
# call _accept_export_fields() after one of this values is changed to reflect across all children.
@export_group("Container Fields")
@export var animator : AnimationPlayer
@export var character : CharacterBody3D
#@export var moves_data_repo : GundyrMovesData
#@export var resources : HFSMResources
#@export var weapons : Array[Weapon]

# Default target player. Game doesn't have two players for now.
@export var player : CharacterBody3D :
	set(new_player):
		player = new_player
		if owner.is_node_ready():
			_accept_export_fields() # pass player to children.

# These fields must be set for each state indivdually.
# states without animation and backend animation (containers) don't need animation field
@export_group("Move Fields")
@export var move_name : String
@export var animation : String
@export var backend_animation : String
#var enter_state_time : float
var state_time : float = 0.0

var moves : Dictionary # { String : EntityHFSM }
var current_move : EntityHFSM = self   
var is_container : bool = false  # automatically sets to true if we have HFSM children


func _ready():
	if move_name == "": 
		move_name = name.to_lower()
	_accept_substates()
	ready()


# Called on initialization phase, automatically builds the inner tree of HFSM
func _accept_substates():
	for child in get_children():
		if child is EntityHFSM:
			is_container = true
			moves[child.move_name] = child

# Due to Godot's scene tree building mechanics (from bottom to top) this method needs
# to be called when the whole HFSM is initialized, so, in @ready of the top level node outside
# of the whole HFSM.
func _accept_export_fields():
	for move in moves.values():
		move.animator = animator
		move.character = character
		move.player = player
		#move.moves_data_repo = moves_data_repo
		#move.resources = resources
		#move.weapons = weapons
		if move.is_container:
			move._accept_export_fields()

# This is being called on physics updates (probably).
# The top level state machine needs the method called from somewhere,
# in this demo we call it from physics update in the top level node Gundyr.
# This is internal method, to override updates use the update(delta) one.
func _update(delta : float):
	state_time += delta
	update(delta)
	if is_container:
		var verdict = current_move.check_transition(delta)
		if verdict.transitions:
			_switch_to(verdict.target_move)
		current_move._update(delta)

func _switch_to(move):
	if current_move != self:
		current_move._on_exit()
	current_move = moves[move]
	current_move._on_enter()
	if not current_move.is_container:
		#print_debug(current_move.animation)
		if animator: animator.play(current_move.animation)

# this function is internal, it works and don't touch it, use on_enter() for customisation
func _on_enter():
	mark_enter_state()
	state_time = 0.0
	on_enter()
	if is_container:
		var first_move_transition = choose_internal_move()
		_switch_to(first_move_transition.target_move)

# this function is internal, it works and don't touch it, use on_exit() for customisation
func _on_exit():
	if is_container:
		current_move._on_exit()
	on_exit()


## Call this from your parent node to use this as the root of your state machine.
func activate_as_root() -> void:
	_accept_export_fields()
	_on_enter()


func ready() -> void: 
	pass


# TransitionData has comments in class definition file
# This is a base implementation that fails fast if you forgot to specify the logic.
# Alternatively, you can make the base implementation "lazy" and lock it transitioning nowhere never.
# The plus is that you won't need do specify the method in heirs, the downside is 
# that the failing fast will be lost. Untill you really embraced the workflow, I recommend spamming
# the empty logics in new heirs, then just refactor it into the locked base method when you 
# start to feel comfortable thinking in HFSM designs.
func check_transition(_delta) -> HFSMTransitionData:
	return HFSMTransitionData.new(true, "implement transition logic for " + move_name) # failing fast
	#return TransitioData.new(false, "")

func choose_internal_move() -> HFSMTransitionData:
	return HFSMTransitionData.new(true, "implement first move choice logic for " + move_name) # failing fast

func update(_delta : float) -> void:
	pass

func on_exit() -> void:
	pass

func on_enter() -> void:
	pass

# our little timestamps framework to work with timings inside our logic
## Deprecated
func mark_enter_state() -> void:
	#enter_state_time = Time.get_unix_time_from_system()
	pass

func get_progress() -> float:
	#var now = Time.get_unix_time_from_system()
	#return now - enter_state_time
	return state_time


# syntatic sugar proxies
func is_progress_longer_than(time : float) -> bool:
	return get_progress() >= time

func is_progress_less_than(time : float) -> bool:
	return get_progress() < time

func is_progress_between(start : float, end : float) -> bool:
	var progress = get_progress()
	return progress >= start and progress <= end

func get_animation_length() -> float:
	if not animator: return 0
	return animator.get_animation(animation).length

func distance_to_player() -> float:
	return character.global_position.distance_to(player.global_position)

func direction_to_player() -> Vector3:
	return character.global_position.direction_to(player.global_position)

func get_lowest_active_state() -> EntityHFSM:
	if is_container:
		return current_move.get_lowest_active_state()
	return self

func coinflip() -> bool:
	return randi() % 2 == 1

# means that we most probably 1 or 2 frames from the end of the lifecycle
func close_to_end_of_animation() -> bool:
	return get_progress() / get_animation_length() > 0.98









# So, how to use all this?
# First, I recommend to design something on paper or in other non-code frameworks.
# Then create a node and attach a new heir of HFSM to it, and select the new HFSM template.
# Then start from defining export fields: move_name always and animation + backed animation if needed.
# Then work with methods template suggests you: 
# First, if you new heir is a container, fill in the choose_internal_move() method
# or delete it if the new heir is bottom-level state.
# Then write down the transition logic for the new heir in check_transition.
# Then if you need, put some custom initializations or destructors in on_enter() and on_exit() methods
# Then lastly, write the update logic. 

# This is the most correct pipeline in my opinion, because the most important thing 
# for any state machine is its transtion logic, 
# and you can test those prior to having any actual updates, if you wrote other methods.

# General code guidelines are: use a shit ton of proxies.
# Ideally, your transition logic needs to consist of several if statements that check
# some single function calls with human readable names, almost like a sentence in english.
# I have a bunch of proxies already in this class under the section of syntaxic sugar, don't
# be ashamed to add your own, and define your own proxies in classes if you need. 
# Check the phase one Combat_1 script for example.
# If you need more complex behaviours, try to find a way to solve your problem
# using backend animations framework. You can learn how attacks lifecycle works to
# get the idea, in short, if you need some data, it's probably beneficial for you
# to work with that data with backend animations.
