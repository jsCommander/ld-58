extends CanvasLayer
class_name DialogManager

@onready var dialog_root: Control = %DialogRoot

func _ready() -> void:
	self.visible = false
	
func open_dialog(scene: PackedScene, data: Dictionary, pause_game := false)-> Signal:
	self.visible = true
	var dialog_instance: BaseDialog = scene.instantiate()

	dialog_root.add_child(dialog_instance)
	dialog_instance.set_data(data)

	dialog_instance.finished.connect(func(_data):
		Logger.log_info(self.name, "Dialog finished")
		dialog_instance.queue_free()
		self.visible = false
		
		if pause_game:
			get_tree().paused = false
	)

	if pause_game:
		get_tree().paused = true

	return dialog_instance.finished
