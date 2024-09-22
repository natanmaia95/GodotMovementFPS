extends BasePauseScreen

func _ready():
	super._ready()
	visible = false
	StageManager.stage_finished.connect(_on_stage_finished)

# removes the base functionality of pressing pause to open it.
func _input(event):
	pass


func open():
	visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	%BtnRestart.grab_focus()
	pass

func close():
	visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass


func _on_stage_finished():
	self._open()


func _on_btn_restart_pressed():
	StageManager.reset_stage()


func _on_btn_exit_pressed():
	StageManager.exit_stage()
