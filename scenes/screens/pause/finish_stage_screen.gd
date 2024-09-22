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
	build_components()
	%BtnRestart.grab_focus()
	pass

func close():
	visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass



func build_components() -> void:
	#results label
	$RichTextLabel.text = "Time: %s %s" % [
		StageManager.timer.as_string(),
		"(NEW RECORD)" if StageManager.current_stage_results["improved_time"] else ""
	]
	$RichTextLabel.text += "\nScore: %d %s" % [
		StageManager.current_stage_results["new_record"]["score"],
		"(NEW RECORD)" if StageManager.current_stage_results["improved_score"] else ""
	]




func _on_stage_finished():
	self._open()

func _on_btn_restart_pressed():
	StageManager.reset_stage()

func _on_btn_exit_pressed():
	StageManager.exit_stage()
