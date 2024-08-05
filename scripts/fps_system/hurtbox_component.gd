@tool
class_name HurtboxComponent
extends Area3D

signal damage_taken(amount)

@export var disabled := false:
	set(value):
		disabled = value
		monitoring = !value
		monitorable = !value
		process_mode = Node.PROCESS_MODE_DISABLED if disabled else PROCESS_MODE_INHERIT

func damage(amount):
	damage_taken.emit(amount)

#func _process(delta):
	#if Input.is_action_just_pressed("jump"):
		#damage(0)
