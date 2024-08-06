class_name FPSGun
extends FPSItem

@export var damage := 100.0 : get = get_damage
@export var max_range := 64.0
@export var deviation := Vector2(5,5)


func get_damage() -> float:
	return damage

func roll_deviation() -> Vector2:
	var x = randf_range(-1.0, 1.0) * deviation.x
	var y = randf_range(-1.0, 1.0) * deviation.y
	return Vector2(x, y)
