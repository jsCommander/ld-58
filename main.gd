extends BaseGame
class_name Game

const START_SCREEN = preload("res://levels/start_screen/start_screen.tscn")
const END_SCREEN = preload("res://levels/end_screen/end_screen.tscn")
const LEVEL_0_INTRO = preload("res://levels/Level0Intro.tscn")
const LEVEL_1 = preload("res://levels/Level1.tscn")
const LEVEL_2 = preload("res://levels/Level2.tscn")
const LEVEL_3 = preload("res://levels/Level3.tscn")
const LEVEL_4 = preload("res://levels/Level4.tscn")
const LEVEL_5 = preload("res://levels/Level5.tscn")

const SCENE_TRANSITIONS: Dictionary[PackedScene, PackedScene] = {
	START_SCREEN: LEVEL_0_INTRO,
	LEVEL_0_INTRO: LEVEL_1,
	LEVEL_1: LEVEL_2,
	LEVEL_2: LEVEL_3,
	LEVEL_3: LEVEL_4,
	LEVEL_4: LEVEL_5,
	LEVEL_5: END_SCREEN,
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
