extends BasePauseScreen

@export var can_restart_with_key := true

func _ready():
	super._ready()
	visible = false

func _open():
	if not Utils.is_mouse_captured(): return
	if StageManager.is_stage_finished: return
	
	super._open()


func _unhandled_input(event:InputEvent) -> void:
	super(event)
	if event.is_action_pressed("restart") and can_restart_with_key:
		try_restart_level()


func open():
	visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$Control/MarginContainer/VBoxContainer/BtnContinue.grab_focus()
	pass

func close():
	visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass


func _on_btn_continue_pressed():
	_close()

func _on_btn_restart_pressed():
	try_restart_level()

func _on_btn_quit_pressed():
	get_tree().paused = false
	StageManager.exit_stage()

func try_restart_level():
	if not StageManager.has_seen_intro: return
	get_tree().paused = false
	StageManager.reset_stage()
