extends MarginContainer


func _process(_delta):
	#if not StageManager.has_seen_intro:
	#	%LblTimer.text = "Timer is not active."
	#else:
	var seconds : float = StageManager.timer.get_frames_in_seconds()
	var minutes = floor(seconds / 60.0)
	seconds -= minutes*60.0
	var milliseconds : int = floor((seconds - floor(seconds))*1000)
	seconds = float(seconds)
	%LblTimer.text = "%03d:%02d:%03d" % [minutes, seconds, milliseconds]

