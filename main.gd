extends BaseGame
class_name Game

const START_SCREEN = preload("res://levels/start_screen/start_screen.tscn")
const END_SCREEN = preload("res://levels/end_screen/end_screen.tscn")

const SCENE_TRANSITIONS: Dictionary[PackedScene, PackedScene] = {
	START_SCREEN: END_SCREEN,
	END_SCREEN: START_SCREEN
}

func _ready() -> void:
	super._ready()
	load_scene(START_SCREEN)

func handle_scene_finished(_data: Dictionary) -> void:
	super.handle_scene_finished(_data)

	var next_scene = SCENE_TRANSITIONS[current_scene]

	if next_scene:
		load_scene(next_scene)
