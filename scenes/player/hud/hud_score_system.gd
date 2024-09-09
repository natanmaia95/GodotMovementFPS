extends MarginContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	ScoreManager.action_added_to_history.connect(on_score_action_added)
	ScoreManager.multiplier_changed.connect(on_multiplier_changed)
	pass # Replace with function body.

func get_last_x_actions(amount:int) -> Array[ScoreAction]:
	var length := ScoreManager.action_history.size()
	var slice := ScoreManager.action_history.slice(-amount, length)
	return slice

func _process(_delta):
	%ComboTimerBar.value = 100.0 * ScoreManager.combo_timer / ScoreManager.COMBO_TIMER_REFRESH_AMOUNT

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
