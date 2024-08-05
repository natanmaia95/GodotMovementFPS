extends Node3D

func _ready():
	$HurtboxComponent.damage_taken.connect(_on_damage_taken)

func _on_damage_taken(_amount):
	var tween = create_tween()
	tween.tween_callback($HurtboxComponent.set.bind("disabled", true))
	tween.tween_property(self, "visible", false, 0.01)
	tween.tween_interval(2.0)
	tween.tween_callback($HurtboxComponent.set.bind("disabled", false))
	tween.tween_property(self, "visible", true, 0.01)
