class_name FinishStageArea
extends PlayerDetectorComponent
var freeze_timer = Timer.new()

func on_player_entered(_player:CharacterBody3D) -> void:
	var did_finish = StageManager.finish_stage()
	if not did_finish: return
	
	disabled = true
	#Engine.time_scale = 0.2
	#await get_tree().create_timer(2.0, true, false, true).timeout
	#Engine.time_scale = 1.0
	#StageManager.exit_stage()
