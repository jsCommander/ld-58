extends Area2D
class_name PartDropZone

@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	_animate()

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		var player = body as Player
		player.reset_parts_to_default()

func _animate():	
	var current_color = sprite_2d.modulate
	var darker_color = current_color.lerp(Color.BLACK, 0.3)

	var tween = create_tween().set_loops()
	tween.tween_property(sprite_2d, "modulate", darker_color, 0.8) 
	tween.tween_property(sprite_2d, "modulate", current_color, 0.8)
	
