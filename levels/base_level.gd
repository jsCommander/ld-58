extends BaseGameScene
class_name BaseLevel

const DIALOG_CONVERSATION = preload("res://game_kit/dialogs/dialog_conversation/dialog_conversation.tscn")
const DIALOG_PAUSE = preload("res://game_kit/dialogs/dialog_pause.tscn")

@onready var music: AudioStreamPlayer = %Music
@onready var player: CharacterBody2D = $Player
@onready var camera_man: CameraMan = $CameraMan
@onready var dialog_manager: DialogManager = $DialogManager

var visited_dialog_zones: Array[String] = []

func _ready() -> void:
	super._ready()
	_connect_player_signals()
	_connect_dialog_zone_signals()
	_connect_level_finish_signals()
	camera_man.follow_target(player)
	camera_man.zoom_to(0.8)
	get_window().grab_focus()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		var result = await dialog_manager.open_dialog(DIALOG_PAUSE, {}, true)

		if result.has("exit"):
			get_tree().quit()
			return

func set_data(_data: Dictionary) -> void:
	super.set_data(_data)
	if _data.has("visited_dialog_zones"):
		visited_dialog_zones = _data.visited_dialog_zones

func _connect_player_signals() -> void:
	player.killed.connect(handle_player_killed)

func _connect_dialog_zone_signals() -> void:
	var nodes = get_tree().get_nodes_in_group("dialog_zone")
	for node in nodes:
		var dialog_zone = node as DialogZone
		dialog_zone.player_entered.connect(handle_dialog_zone_player_entered)
		
func _connect_level_finish_signals() -> void:
	var nodes = get_tree().get_nodes_in_group("level_finish")
	for node in nodes:
		var level_finish = node as LevelFinish
		level_finish.player_entered.connect(handle_level_finish_player_entered)

func handle_level_finish_player_entered() -> void:
	finished.emit({})

func handle_player_killed() -> void:
	reload_requested.emit({"visited_dialog_zones": visited_dialog_zones})

func handle_dialog_zone_player_entered(_dialog_name: String, conversation: Conversation) -> void:
	if visited_dialog_zones.has(_dialog_name):
		return

	visited_dialog_zones.append(_dialog_name)

	var _result = await dialog_manager.open_dialog(DIALOG_CONVERSATION, {"conversation": conversation}, true)


func _on_music_finished() -> void:
	music.play()
