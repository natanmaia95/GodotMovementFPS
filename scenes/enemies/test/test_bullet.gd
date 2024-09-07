extends Projectile3D

func _on_hitbox_component_after_hurtbox_hit(hurtbox):
	queue_free()

func _on_hitbox_component_body_entered(body):
	queue_free()
