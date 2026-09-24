extends MarginContainer

var vignete_material : ShaderMaterial

# Called when the node enters the scene tree for the first time.
func _ready():
	ScoreManager.action_added_to_history.connect(on_score_action_added)
	ScoreManager.multiplier_changed.connect(on_multiplier_changed)
	vignete_material = %Vignette.material
	pass # Replace with function body.

func get_last_x_actions(amount:int) -> Array[ScoreAction]:
	var length := ScoreManager.action_history.size()
	var slice := ScoreManager.action_history.slice(-amount, length)
	return slice

func _process(_delta):
	var max_timer = ScoreManager.COMBO_TIMER_REFRESH_AMOUNT
	%ComboTimerBar.value = 100.0 * ScoreManager.combo_timer / max_timer
	
	var intensity = -0.2 + (max_timer - ScoreManager.combo_timer) / max_timer
	#%ComboTimerBar.modulate.r = 1.0
	%ComboTimerBar.modulate.g = (1.0 - intensity)
	%ComboTimerBar.modulate.b = (1.0 - intensity)
	if ScoreManager.combo_timer > 0:
		vignete_material.set_shader_parameter("intensity", intensity * 4.0)
	else:
		vignete_material.set_shader_parameter("intensity", 0.0)


func on_multiplier_changed():
	%MultiplierLbl.text = "[center]"
	if ScoreManager.combo_multiplier > 1.0:
		%MultiplierLbl.text += "COMBO x %.0f" % ScoreManager.combo_multiplier
	else:
		%MultiplierLbl.text = ""

func on_score_action_added(_score_action:ScoreAction):
	var slice := get_last_x_actions(4)
	slice.reverse()
	%ActionsListLbl.text = "[center]"
	if ScoreManager.get_score_area_multiplier() == 0.0:
		%ActionsListLbl.text += "[color=red]"
	var count := 0
	for action:ScoreAction in slice:
		%ActionsListLbl.text += "[font_size={%d}]" % (30 - count*4)
		%ActionsListLbl.text += action.name + "\n"
		count += 1
	%ScoreLbl.text = "SCORE: %9d" % ScoreManager.total_score
