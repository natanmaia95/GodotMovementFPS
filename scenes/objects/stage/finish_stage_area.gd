class_name FinishStageArea
extends PlayerDetectorComponent
var freeze_timer = Timer.new()

func on_player_entered(_player:CharacterBody3D) -> void:
	if StageManager.finish_stage(): disabled = true
	get_tree().paused = true
