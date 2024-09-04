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

func _process(delta):
	%ComboTimerBar.value = 100.0 * ScoreManager.combo_timer / 5.0

func on_multiplier_changed():
	%MultiplierLbl.text = "x" + "%.1f" % ScoreManager.combo_multiplier

func on_score_action_added(_score_action:ScoreAction):
	var slice := get_last_x_actions(4)
	slice.reverse()
	%ActionsListLbl.text = ""
	for action:ScoreAction in slice:
		%ActionsListLbl.text += action.name + "\n"
	
	%ScoreLbl.text = "SCORE: %9d" % ScoreManager.total_score
