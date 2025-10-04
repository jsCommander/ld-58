extends CharacterBody2D

@export var head: PartHead
@export var torso: PartTorso
@export var legs: PartLeg

@onready var leg_texture: Sprite2D = %LegTexture
@onready var torso_texture: Sprite2D = %TorsoTexture
@onready var head_texture: Sprite2D = %HeadTexture
@onready var base_rig: BaseRig = $BaseRig

var is_dead = false

func _physics_process(_delta: float) -> void:
	if is_dead:
		return

	var move_direction = Utils.get_move_input_vector()

	if move_direction != Vector2.ZERO:
		velocity = move_direction * legs.speed
	else:
		velocity = Vector2.ZERO

	base_rig.update_walk_animation(velocity)
	base_rig.set_animation_rig_direction(velocity)
	move_and_slide()
	
	_update_parts()

func _update_parts() -> void:
	if leg_texture.texture != legs.texture:
		leg_texture.texture = legs.texture
	if torso_texture.texture != torso.texture:
		torso_texture.texture = torso.texture
	if head_texture.texture != head.texture:
		head_texture.texture = head.texture

func _on_usebox_area_entered(area: Area2D) -> void:
	var body = area.get_parent()

	if not body is PartDrop:
		return

	Logger.log_debug(self.name, "Found part drop: %s" % body.part)

	var part_drop = body as PartDrop
	var part = part_drop.part

	if part is PartLeg:
		legs = part
		Logger.log_debug(self.name, "Updated legs: %s" % part)
	elif part is PartTorso:
		torso = part
		Logger.log_debug(self.name, "Updated torso: %s" % part)
	elif part is PartHead:
		head = part
		Logger.log_debug(self.name, "Updated head: %s" % part)
	else:
		assert(false, "Part type is not valid")

	part_drop.kill()
