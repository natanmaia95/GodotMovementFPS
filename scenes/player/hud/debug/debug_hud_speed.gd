extends Control

@export var character : CharacterBody3D


func _process(delta: float) -> void:
	if character:
		var hor_vel = character.get_horizontal_velocity()
		var ver_vel = character.velocity - hor_vel
		%Label.text = "Hor Speed: %.3f\nVer Speed: %.3f" % [hor_vel.length(), ver_vel.length()]
		
