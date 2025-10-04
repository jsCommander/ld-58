extends Node2D
class_name PartDrop

@export var part: BasePart

@onready var base_rig: BaseRig = $BaseRig

func kill() -> void:
	queue_free()