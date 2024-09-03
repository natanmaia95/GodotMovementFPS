class_name HealthComponent
extends Node3D

signal health_changed(new_value, delta)
signal health_depleted()

@export var max_health := 100.0
var health := 0.0 :
	set(value):
		if health == value: return
		var old_health = health
		health = clamp(value, 0, max_health)
		var delta = health - old_health
		if delta != 0.0:
			health_changed.emit(health, delta)
			if health == 0.0:
				health_depleted.emit()

func _ready():
	health = max_health

func heal(amount:float) -> void:
	health += amount

func damage(amount:float) -> void:
	health -= amount

func hp_rate() -> float:
	return health / max_health
