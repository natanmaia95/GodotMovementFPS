class_name RegeneratingHealthComponent
extends HealthComponent

@export var wait_to_regen := 2.0

## health points per second
@export var regen_rate := 20

var regen_timer := 0.0

func _physics_process(delta):
	if health != max_health and health > 0.0:
		if regen_timer > 0.0:
			regen_timer -= delta
		else:
			health += regen_rate * delta

func damage(amount):
	super(amount)
	regen_timer = wait_to_regen
