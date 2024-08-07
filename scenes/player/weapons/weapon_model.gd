extends Node3D


func _ready():
	if $TestCamera: $TestCamera.queue_free()

func get_anim_player() -> AnimationPlayer:
	return $AnimationPlayer

func play(anim_name:String, from_start:=true) -> void:
	if from_start:
		stop()
	$AnimationPlayer.play(anim_name)

func queue(anim_name:String) -> void:
	$AnimationPlayer.queue(anim_name)

func stop() -> void:
	$AnimationPlayer.stop()
