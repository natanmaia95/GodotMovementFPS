class_name StageRecord
extends Resource


## Time is saved as ticks, 1/60th of a second in length.
@export var time : int = 999999999999

@export var score : int = 0



#TODO
static func make_best_of(new:StageRecord, old:StageRecord):
	var best_record : = StageRecord.from_dict(old.to_dict())
	var dict = {
		"new_record": new,
		"old_record": old,
		"best_record": best_record,
		"improved_time": false, 
		"improved_score": false
	}
	
	if new.time < old.time:
		best_record.time = new.time
		dict["improved_time"] = true
	
	if new.score > old.score:
		best_record.score = new.score
		dict["improved_score"] = true
	
	return dict


static func from_dict(dict:Dictionary) -> StageRecord:
	var record : = StageRecord.new()
	if dict.has("time"): record.time = dict["time"]
	if dict.has("score"): record.score = dict["score"]
	return record


func to_dict() -> Dictionary:
	return {
		#resets
		"time": time,
		"score": score
	}
