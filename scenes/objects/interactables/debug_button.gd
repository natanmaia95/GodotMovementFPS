extends Node3D

@export var toggled : bool = false
@export var message_on : String = "Button pressed."
@export var message_off : String = "Button unpressed."

func _ready():
	$InteractableComponent.interacted.connect(on_interacted)

func on_interacted(_source:Node3D):
	toggled = !toggled
	$Model/CSGCylinder3D.position.y = 0.15 + (0.0 if toggled else 0.1)
	if toggled:
		print_debug(message_on, " ", self)
	else:
		print_debug(message_off, " ", self)
