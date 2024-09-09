class_name ScoreAreaDetectorComponent
extends Area3D



func _ready():
	collision_layer = 0
	collision_mask = 0
	set_collision_mask_value(FPSDefs.PhysicsLayers.SCORE_AREA, true)
	ScoreManager.score_area_detector = self

func get_score_areas() -> Array:
	return get_overlapping_areas().filter(
		func(area): return area is ScoreArea3D
	)

func get_best_area() -> ScoreArea3D:
	var areas = get_score_areas()
	if areas == []: return null
	
	var best_area : ScoreArea3D = null
	
	for area:ScoreArea3D in areas:
		if not area.can_trick(): 
			continue
		if best_area != null and best_area.global_position.distance_to(self.global_position) < area.global_position.distance_to(self.global_position):
			continue
		best_area = area
	
	return best_area

func increase_trick_count() -> void:
	var area = get_best_area()
	if area:
		area.increase_trick_count()
