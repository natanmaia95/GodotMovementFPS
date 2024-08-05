extends Node


const MAX_COMBO_MULTIPLIER : float = 100.0

var action_history : Array[ScoreAction] = []
var total_score : int = 0

var combo_multiplier : float = 1.0
var combo_timer : float = 0.0


func reset():
	action_history.clear()
	total_score = 0
	combo_multiplier = 1.0
	combo_timer = 0.0
	pass
