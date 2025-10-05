extends Area2D
class_name PartDropZone

@onready var label: Label = $Label

func _ready() -> void:
	label.visible = false

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.drop_all_parts()
