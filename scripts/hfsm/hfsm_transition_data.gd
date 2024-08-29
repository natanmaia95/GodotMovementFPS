extends Resource
class_name HFSMTransitionData

var transitions : bool
var target_move : String
var data : Dictionary = {}

# think ten times before you do, but you can send other data between your states

func _init(verdict : bool, next_move : String):
	transitions = verdict
	target_move = next_move

static func empty() -> HFSMTransitionData:
	return HFSMTransitionData.new(false, "")
