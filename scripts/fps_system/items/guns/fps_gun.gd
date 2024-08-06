class_name FPSGun
extends FPSItem
## Default gun behavior is "Single shot, with a small cooldown between shots"
## Create a new gun instance with ``duplicate()``.


@export var damage := 100.0 : get = get_damage
@export var max_range := 64.0
@export var deviation := Vector2(5,5)
@export var shot_cooldown := 0.1
@export var can_auto_fire := false
@export var auto_fire_penalty := 0.1

@export var magazine_size : int = 6
var current_ammo : int = 0



func _init():
	current_ammo = magazine_size

func can_fire():
	return current_ammo > 0

func can_alt_fire():
	return false

func get_damage() -> float:
	return damage

func get_random_deviation() -> Vector2:
	var x = randf_range(-1.0, 1.0) * deviation.x
	var y = randf_range(-1.0, 1.0) * deviation.y
	return Vector2(x, y)
