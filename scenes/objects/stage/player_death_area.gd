class_name PlayerDeathArea
extends PlayerDetectorComponent

func on_player_entered(player:CharacterBody3D) -> void:
	var health_component = player.find_child("HealthComponent")
	if health_component and health_component is HealthComponent:
		health_component.health = 0
