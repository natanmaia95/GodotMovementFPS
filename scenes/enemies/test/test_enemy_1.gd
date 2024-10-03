extends CharacterBody3D

@export var state_machine : Node
@export var sprite : Sprite3D

var sprites = {
	"idle": preload("res://images/enemies/test_enemy_idle.png"),
	"search": preload("res://images/enemies/test_enemy_search.png"),
	"shoot": preload("res://images/enemies/test_enemy_shoot.png"),
	"defeated": preload("res://images/enemies/test_enemy_defeated.png")
}

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

func _process(_delta):
	%DbgLblState.text = state_machine.get_lowest_active_state().name

func set_sprite(frame_name:String):
	if sprites.has(frame_name):
		sprite.texture = sprites[frame_name]
