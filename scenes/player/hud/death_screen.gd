extends MarginContainer


func _ready():
	get_parent().died.connect(_on_player_died)
	visible = false


func _on_player_died() -> void:
	get_tree().paused = true
	visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	%BtnRestart.grab_focus()
	pass


func _on_btn_restart_pressed():
	StageManager.reset_stage()

func _on_btn_exit_pressed():
	StageManager.exit_stage()
