extends Node
class_name BaseGameScene

signal finished(data: Dictionary)
signal reload_requested(data: Dictionary)

func _ready() -> void:
	
	finished.connect(func(data: Dictionary): Logger.log_info(self.name, "scene is finished: %s" % data))
	reload_requested.connect(func(data: Dictionary): Logger.log_info(self.name, "scene reload requested: %s" % data))
	
	get_window().grab_focus()
