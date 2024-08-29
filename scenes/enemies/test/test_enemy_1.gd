extends CharacterBody3D

@export var state_machine : Node

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	if state_machine and state_machine is EntityHFSM:
		state_machine.activate_as_root()

func _physics_process(delta):
	if state_machine:
		state_machine._update(delta)
