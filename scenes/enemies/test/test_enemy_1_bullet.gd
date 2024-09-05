extends Projectile3D


func update(_delta):
	pass

func _on_hitbox_after_hurtbox_hit(_hurtbox):
	queue_free()
