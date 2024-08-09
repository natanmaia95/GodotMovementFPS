@tool
extends InteractableComponent

# The character can only aim at this grapple point if the view is unobscured
func can_hover(character:Node3D) -> bool:
	var space_state : PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	
	var origin = self.global_position
	var end = character.global_position # feet
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.exclude = [character]
	var result = space_state.intersect_ray(query)
	if not result: return true
	return !result.collider
