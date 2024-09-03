extends MarginContainer


@export var health_component : HealthComponent


func _process(delta):
	if health_component:
		%ProgressBar.value = health_component.hp_rate() * 100
