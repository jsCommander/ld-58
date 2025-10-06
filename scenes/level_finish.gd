extends Area2D
class_name LevelFinish

signal player_entered()

@onready var label: Label = $Label

func _ready() -> void:
	add_to_group("level_finish")
	label.visible = false

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player_entered.emit()
