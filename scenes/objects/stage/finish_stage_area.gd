extends PlayerDetectorComponent

func on_player_entered(_player:CharacterBody3D) -> void:
	if StageManager.finish_stage(): disabled = true
