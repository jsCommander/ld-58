extends BaseGameScene

@onready var music: AudioStreamPlayer = %Music

func _on_level_music_finished() -> void:
	music.play()

func _on_music_finished() -> void:
	music.play()

func _on_restart_button_button_down() -> void:
	finished.emit({})

func _on_exit_button_button_down() -> void:
	get_tree().quit()
