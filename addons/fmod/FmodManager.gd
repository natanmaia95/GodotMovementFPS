@tool
extends Node

func _ready():
	process_mode = PROCESS_MODE_ALWAYS
	add_child(PerformancesDisplay.new())

#func _process(delta):
	#FmodServer.update()
	#pass
	#
#func _notification(what):
	#FmodServer.notification(what)
	#pass
