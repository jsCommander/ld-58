extends Node2D

@onready var collision_shape_2d: CollisionShape2D = %CollisionShape2D

func _on_usebox_body_entered(body: Node2D) -> void:
	if body is Player:
		var player = body as Player
		if player.legs.set_type == Types.SetType.DEMON:
			collision_shape_2d.set_deferred("disabled", true)


func _on_usebox_body_exited(body: Node2D) -> void:
	if body is Player:
		collision_shape_2d.set_deferred("disabled", false)
