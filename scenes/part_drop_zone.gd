extends Area2D
class_name PartDropZone

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.drop_all_parts()
