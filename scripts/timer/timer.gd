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






static func seconds_from_ticks(ticks_in:int) -> float:
	return float(ticks_in) / float(Engine.physics_ticks_per_second)

static func string_from_ticks(ticks_in:int) -> String:
	return string_from_seconds(seconds_from_ticks(ticks_in))

static func string_from_seconds(seconds_in:float) -> String:
	
	var int_seconds : int = int(seconds_in)
	var int_minutes : int = int(int_seconds / 60)
	var int_millis : int = int((seconds_in - int_seconds)*1000)
	int_seconds = int_seconds % 60
	
	var time_string = "%02d:%02d.%03d" % [int_minutes, int_seconds, int_millis]
	return time_string



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

func timer_as_string() -> String:
	return string_from_ticks(ticks)
