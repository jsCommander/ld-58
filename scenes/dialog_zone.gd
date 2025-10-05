extends Area2D
class_name DialogZone

@export var speakers: ConversationSpeakerArray
@export_file("*.json") var json_file: String

signal player_entered(conversation: Conversation)

@onready var label: Label = $Label

var conversation: Conversation
var is_visited: bool = false

func _ready() -> void:
	label.visible = false
	add_to_group("dialog_zone")
	conversation = Conversation.new()
	conversation.speakers = speakers
	conversation.json_file = json_file

func _on_body_entered(body: Node2D) -> void:
	if body is Player and not is_visited:
		is_visited = true
		player_entered.emit(conversation)
