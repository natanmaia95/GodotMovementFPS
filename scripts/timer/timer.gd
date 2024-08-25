class_name TimerResource
extends Resource
## Timer resource
## meant to be used with a global Timer loaded from game files,
## but can be instantiated on a case-by-case basis.

## How many in_game frames have been measured. More precise than 
## Is correctly updated by calling update inside _physics_process.
var ticks : int = 0

## How much time has been measured. For precision use [code]ticks[/code] instead.
## Is correctly updated by calling update inside normal _process.
var seconds : float = 0.0


func reset() -> void:
	ticks = 0
	seconds = 0.0


## Call inside a level's process or physics process functions.
func update(delta:float) -> void:
	ticks += 1
	seconds += delta


## Useful shorthand for records.
func get_frames_in_seconds() -> float:
	return float(ticks) / float(Engine.physics_ticks_per_second)
