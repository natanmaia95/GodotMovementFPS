@tool
class_name HitboxComponent
extends Area3D

signal after_hurtbox_hit(hurtbox:HurtboxComponent)
signal lifetime_expired

@export var disabled := false:
	set(value):
		disabled = value
		set_deferred("monitoring", !value)
		set_deferred("monitorable", !value)
		set_deferred("process_mode", Node.PROCESS_MODE_DISABLED if disabled else PROCESS_MODE_INHERIT)
		if value == false:
			areas_to_ignore = []

# values defined in FpsDefs
@export_flags("Player:1", "Enemy:2") var target_types : int = 0:
	set(value):
		target_types = value
		set_collision_mask_value(FPSDefs.PhysicsLayers.PLAYER_HURTBOX, value & 1)
		set_collision_mask_value(FPSDefs.PhysicsLayers.ENEMY_HURTBOX, value & 2)

# impact
@export var DAMAGE: float = 4
@export var HITSTUN: float = 0.0

## lifespan of 0 or negative makes it always active.
@export var LIFESPAN: float = 0.5
var lifetime := 0.0

var areas_to_ignore_permanently : Array[Area3D] = []
var areas_to_ignore : Array[Area3D] = []


func _ready():
	if Engine.is_editor_hint():
		collision_layer = 0
		collision_mask = 0
		target_types = target_types
		return
	area_entered.connect(_on_area_entered)


func should_ignore_area(area : Area3D) -> bool:
	return area in areas_to_ignore or area in areas_to_ignore_permanently


func _physics_process(delta:float) -> void:
	if not _update_lifetime(delta):
		return
	update(delta)


func _update_lifetime(delta:float) -> bool:
	if LIFESPAN > 0:
		#print("update lifetime")
		lifetime += delta
		
		if lifetime >= LIFESPAN: 
			lifetime_expired.emit()
			queue_free()
			return false
	return true
 

func _on_area_entered(area:Area3D):
	if area is HurtboxComponent:
		if not should_ignore_area(area):
			var hurtbox := area as HurtboxComponent
			
			hit_hurtbox(hurtbox)
			areas_to_ignore.push_back(hurtbox)
			
			on_after_hurtbox_hit(hurtbox)
			after_hurtbox_hit.emit(hurtbox)


func hit_hurtbox(hurtbox : HurtboxComponent) -> void:
	hurtbox.damage(DAMAGE)
	# TODO: add stun, add knockback


func update(delta) -> void: pass

func on_after_hurtbox_hit(hurtbox : HurtboxComponent) -> void:
	pass
