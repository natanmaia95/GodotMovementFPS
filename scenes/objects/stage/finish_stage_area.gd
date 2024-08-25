extends PlayerDetectorComponent

func on_player_entered(player:CharacterBody3D) -> void:
	if StageManager.finish_stage(): disabled = true
