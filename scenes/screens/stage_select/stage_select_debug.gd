extends Node


func _ready():
	#StageManager.stage_info_loaded.connect(_on_stage_info_loaded) #already loaded
	_on_stage_info_loaded()


func _on_stage_info_loaded() -> void:
	for stage_info : StageInfo in StageManager.stages_list.values():
		var btn = Button.new()
		btn.text = stage_info.name
		btn.pressed.connect(_on_stage_btn_pressed.bind(stage_info.key))
		print_debug(btn, btn.text)
		%StageListContainer.add_child(btn)


func _on_stage_btn_pressed(stage_key:String) -> void:
	StageManager.goto_stage(stage_key)
	#get_tree().change_scene_to_packed(stage_info.stage_packed_scene)
