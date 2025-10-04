extends BaseGameScene
class_name BaseLevel

@onready var music: AudioStreamPlayer = %Music
@onready var player: CharacterBody2D = $Player
@onready var camera_man: CameraMan = $CameraMan

func _ready() -> void:
	super._ready()
	camera_man.follow_target(player)
	get_window().grab_focus()


func _on_level_finish_body_entered(_body: Node2D) -> void:
	finished.emit({})
