extends Area2D
class_name PartDropZone

@export var drop_force: int = 100

@onready var label: Label = $Label

func _ready() -> void:
	label.visible = false

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		var drop_direction = global_position.direction_to(body.global_position)
		body.drop_all_parts(drop_direction, drop_force)
