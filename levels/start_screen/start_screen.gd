extends BaseGameScene

@onready var music: AudioStreamPlayer = %Music

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton or event is InputEventJoypadButton or event is InputEventScreenTouch:
		handle_user_input()

func _unhandled_key_input(_event: InputEvent) -> void:
	handle_user_input()

func handle_user_input() -> void:
	finished.emit({})

func _on_level_music_finished() -> void:
	music.play()
