extends Projectile3D

func _on_hitbox_component_after_hurtbox_hit(_hurtbox):
	queue_free()

func _on_hitbox_component_body_entered(_body):
	queue_free()
