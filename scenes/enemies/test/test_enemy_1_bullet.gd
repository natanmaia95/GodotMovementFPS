extends Projectile3D


func update(delta):
	pass

func _on_hitbox_after_hurtbox_hit(hurtbox):
	queue_free()
