extends BaseGameScene
class_name BaseLevel

const DIALOG_CONVERSATION = preload("res://game_kit/dialogs/dialog_conversation/dialog_conversation.tscn")

@onready var music: AudioStreamPlayer = %Music
@onready var player: CharacterBody2D = $Player
@onready var camera_man: CameraMan = $CameraMan
@onready var dialog_manager: DialogManager = $DialogManager

func _ready() -> void:
	super._ready()
	_connect_player_signals()
	_connect_dialog_zone_signals()
	camera_man.follow_target(player)
	get_window().grab_focus()


func _on_level_finish_body_entered(_body: Node2D) -> void:
	finished.emit({})

func _connect_player_signals() -> void:
	player.killed.connect(handle_player_killed)

func _connect_dialog_zone_signals() -> void:
	var nodes = get_tree().get_nodes_in_group("dialog_zone")
	for node in nodes:
		var dialog_zone = node as DialogZone
		dialog_zone.player_entered.connect(handle_dialog_zone_player_entered)

func handle_player_killed() -> void:
	reload_requested.emit({})

func handle_dialog_zone_player_entered(conversation: Conversation) -> void:
	dialog_manager.open_dialog(DIALOG_CONVERSATION, {"conversation": conversation}, true)
