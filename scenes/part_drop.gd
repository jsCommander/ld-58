extends Node2D
class_name PartDrop

@export var part: BasePart

@onready var base_rig: BaseRig = $BaseRig
@onready var usebox_collider: CollisionShape2D = $Usebox/UseboxCollider

func kill() -> void:
	queue_free()

func disable_usebox(duration: float = 0.0) -> void:
	if duration > 0.0:
		usebox_collider.set_deferred("disabled", true)
		await get_tree().create_timer(duration).timeout
		usebox_collider.set_deferred("disabled", false)
	else:
		usebox_collider.set_deferred("disabled", true)

func enable_usebox() -> void:
	usebox_collider.set_deferred("disabled", false)
