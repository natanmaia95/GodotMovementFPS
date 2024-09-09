class_name StageInfo
extends Resource

@export var key : String

@export var name : String

@export var image : Texture2D

@export var stage_packed_scene : PackedScene


func serialize():
	var data = inst_to_dict(self)
	return data

func deserialize(_data:Dictionary):
	pass
