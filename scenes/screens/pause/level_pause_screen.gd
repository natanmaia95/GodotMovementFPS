extends BasePauseScreen

@export var can_restart_with_key := true

@onready var sens_slider: HSlider = $Control/MarginContainer/VBoxContainer/SensSlider



func _ready():
	super._ready()
	visible = false
	_setup_sensitivity_slider()

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

func _setup_sensitivity_slider() -> void:
	sens_slider.min_value = 0.1
	sens_slider.max_value = 3.0
	sens_slider.step = 0.05
	sens_slider.set_value_no_signal(FPSController.mouse_sensitivity_multiplier)
	sens_slider.value_changed.connect(_on_sens_slider_value_changed)

func _on_sens_slider_value_changed(new_value: float) -> void:
	FPSController.mouse_sensitivity_multiplier = new_value
	
