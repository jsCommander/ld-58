extends Area2D
class_name PartDropZone

@export var drop_force: int = 100

@onready var label: Label = $Label
@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	label.visible = false
	_animate()

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		var drop_direction = global_position.direction_to(body.global_position)
		body.drop_all_parts(drop_direction, drop_force)

func _animate():
	var random_delay = randf_range(0.0, 1)
	await get_tree().create_timer(random_delay).timeout
	
	var current_color = sprite_2d.modulate
	var darker_color = current_color.lerp(Color.BLACK, 0.3)

	var tween = create_tween().set_loops()
	tween.tween_property(sprite_2d, "modulate", darker_color, 0.8) 
	tween.tween_property(sprite_2d, "modulate", current_color, 0.8)
	
