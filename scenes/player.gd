extends CharacterBody2D
class_name Player

const BULLET = preload("res://scenes/bullet.tscn")
const PART_DROP = preload("res://scenes/part_drop.tscn")

@export var head: PartHead
@export var torso: PartTorso
@export var legs: PartLeg

signal killed()

@onready var leg_texture: Sprite2D = %LegTexture
@onready var torso_texture: Sprite2D = %TorsoTexture
@onready var head_texture: Sprite2D = %HeadTexture
@onready var base_rig: BaseRig = $BaseRig
@onready var hurt_sfx: AudioStreamPlayer2D = %HurtSfx
@onready var health_bar: ProgressBar = %HealthBar
@onready var hurtbox_collider: CollisionShape2D = %HurtboxCollider

var is_dead = false
var is_shoot_cooldown: bool = false
var is_invulnebility: bool = false
var current_health: int = 0

func _ready() -> void:
	_update_health(torso.max_health)

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

	if Input.is_action_pressed("action_main"):
		_spawn_bullet(get_global_mouse_position())

	_update_parts()

func apply_damage(damage: int, attacker: Node2D) -> void:
	if is_dead or is_invulnebility:
		return

	_update_health(current_health - damage)
	
	Logger.log_debug(self.name, "Applied damage: %s from %s" % [damage, attacker.name])
	
	base_rig.flash()
	hurt_sfx.play()

	if torso.invulnebility_time > 0.0:
		_start_invulnebility(torso.invulnebility_time)

func kill() -> void:
	if is_dead:
		return

	is_dead = true
	killed.emit()

func _update_health(health: int) -> void:
	current_health = clamp(health, 0, torso.max_health)
	health_bar.value = current_health
	health_bar.max_value = torso.max_health

	if current_health <= 0:
		kill()

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
	var old_part: BasePart

	if part is PartLeg:
		old_part = legs
		legs = part
		Logger.log_debug(self.name, "Updated legs: %s" % part)

	elif part is PartTorso:
		old_part = torso
		torso = part

		Logger.log_debug(self.name, "Updated torso: %s" % part)
	elif part is PartHead:
		old_part = head
		head = part
		Logger.log_debug(self.name, "Updated head: %s" % part)
	else:
		assert(false, "Part type is not valid")

	part_drop.kill()

	var old_part_drop = PART_DROP.instantiate()
	old_part_drop.part = old_part
	old_part_drop.global_position = part_drop.global_position
	get_tree().root.add_child(old_part_drop)
	old_part_drop.disable_usebox(2.0)

func _spawn_bullet(fly_direction: Vector2) -> void:
	if not torso.bullet:
		Logger.log_debug(self.name, "Can't spawn bullet, no bullet stat")
		return

	if is_shoot_cooldown:
		return

	var bullet = BULLET.instantiate()
	bullet.stat = torso.bullet

	get_tree().root.add_child(bullet)
	bullet.init_bullet(global_position, fly_direction)

	_start_shoot_cooldown(torso.shoot_cooldown)

func _start_shoot_cooldown(cooldown: float) -> void:
	is_shoot_cooldown = true
	await get_tree().create_timer(cooldown).timeout
	is_shoot_cooldown = false

func _start_invulnebility(time: float) -> void:
	is_invulnebility = true
	hurtbox_collider.set_deferred("disabled", true)
	await get_tree().create_timer(time).timeout
	is_invulnebility = false
	hurtbox_collider.set_deferred("disabled", false)
