class_name ResetStageArea
extends PlayerDetectorComponent

func on_player_entered(_player:CharacterBody3D) -> void:
	StageManager.reset_stage.call_deferred()
