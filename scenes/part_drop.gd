@tool
extends Node2D
class_name PartDrop

@export var part: BasePart:
	set(value):
		_part = value
		_update_textures()
	get:
		return _part

@onready var base_rig: BaseRig = $BaseRig
@onready var usebox_collider: CollisionShape2D = $Usebox/UseboxCollider
@onready var head_texture: Sprite2D = %HeadTexture
@onready var torso_texture: Sprite2D = %TorsoTexture
@onready var leg_texture: Sprite2D = %LegTexture

var _part: BasePart

func _ready() -> void:
	#base_rig.start_pulse_animation()
	_update_textures()

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

func _update_textures() -> void:
	if not is_node_ready():
		return

	head_texture.visible = _part is PartHead
	torso_texture.visible = _part is PartTorso
	leg_texture.visible = _part is PartLeg

	if _part is PartHead:
		head_texture.texture = _part.texture
	elif _part is PartTorso:
		torso_texture.texture = _part.texture
	elif _part is PartLeg:
		leg_texture.texture = _part.texture
