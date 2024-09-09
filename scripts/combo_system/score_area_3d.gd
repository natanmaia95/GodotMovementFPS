class_name ScoreArea3D
extends Area3D

@export var multiplier : float = 1.0

@export var max_tricks : int = 30
var tricks : int = 0

func _ready():
	collision_layer = 0
	collision_mask = 0
	set_collision_layer_value(FPSDefs.PhysicsLayers.SCORE_AREA, true)
	tricks = 0

func can_trick(score_action:ScoreAction=null) -> bool:
	if not score_action:
		return tricks < max_tricks
	if score_action.is_parkour:
		return tricks < max_tricks
	return true # if not parkour, can trick :)

func increase_trick_count() -> void:
	tricks = min(tricks + 1, max_tricks)
