class_name PlayerDetectorComponent
extends Area3D

@export var disabled := false:
	set(value):
		disabled = value
		set_deferred("monitoring", !value)
		set_deferred("monitorable", !value)
		set_deferred("process_mode", Node.PROCESS_MODE_DISABLED if disabled else PROCESS_MODE_INHERIT)

@export var disable_on_first_trigger := false

signal player_entered(player:CharacterBody3D)

func _ready():
	body_entered.connect(on_body_entered)

func on_body_entered(body) -> void:
	if body is FPSController or (body.is_in_group("PLAYER") and body is CharacterBody3D):
		on_player_entered(body)
		player_entered.emit(body)
		if disable_on_first_trigger:
			disabled = true

func on_player_entered(player:CharacterBody3D) -> void: pass
