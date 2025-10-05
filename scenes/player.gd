@tool
extends CharacterBody2D
class_name Player

const BULLET = preload("res://scenes/bullet.tscn")
const PART_DROP = preload("res://scenes/part_drop.tscn")

const GHOST_HEAD = preload("res://resources/parts/ghost_head.tres")
const GHOST_LEG = preload("res://resources/parts/ghost_leg.tres")
const GHOST_TORSO = preload("res://resources/parts/ghost_torso.tres")

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
@onready var bullet_spawn: Marker2D = %BulletSpawn
@onready var shoot_sfx: AudioStreamPlayer2D = %ShootSfx
@onready var damage_number: DamageNumber = $BaseRig/DamageNumber
@onready var death_sfx: AudioStreamPlayer2D = %DeathSfx
@onready var usebox_collider: CollisionShape2D = %UseboxCollider

var is_dead = false
var is_shoot_cooldown: bool = false
var is_invulnebility: bool = false
var current_health: int = 0

func _ready() -> void:
	add_to_group("player")
	_update_health(torso.max_health)
	_update_parts()

func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint():
		_update_parts()
		return
	
	if is_dead:
		return

	var move_direction = Utils.get_move_input_vector()

	if move_direction != Vector2.ZERO:
		velocity = move_direction * legs.speed
	else:
		velocity = Vector2.ZERO

	base_rig.update_walk_animation(velocity)
	#base_rig.set_animation_rig_direction(velocity)
	move_and_slide()

	if Input.is_action_pressed("action_main"):
		_spawn_bullet(get_global_mouse_position())

	_update_parts()

func apply_damage(damage: int, attacker: Node2D, knockback_force: int = 0) -> void:
	if is_dead or is_invulnebility:
		return
	
	var damage_to_apply = clamp(damage, 0, current_health)
	_update_health(current_health - damage_to_apply)
	damage_number.spawn("-%d" % damage_to_apply, Vector2.UP)
	
	var attack_direction = attacker.global_position.direction_to(global_position).normalized()

	if knockback_force > 0.0:
		var knockback_velocity = attack_direction * knockback_force * 100
		var old_velocity = velocity
		velocity = knockback_velocity
		move_and_slide()

		velocity = old_velocity
	
	flash()
	hurt_sfx.play()

	if torso.invulnebility_time > 0.0:
		_start_invulnebility(torso.invulnebility_time)

func kill() -> void:
	if is_dead:
		return

	is_dead = true
	killed.emit()
	base_rig.visible = false

	hurtbox_collider.set_deferred("disabled", true)
	usebox_collider.set_deferred("disabled", true)

	death_sfx.play()
	await death_sfx.finished
	queue_free()

func _update_health(health: int) -> void:
	current_health = clamp(health, 0, torso.max_health)
	health_bar.max_value = torso.max_health
	health_bar.value = current_health

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

	if body is PartDrop:
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

		if old_part != GHOST_HEAD and old_part != GHOST_TORSO and old_part != GHOST_LEG:
			_spawn_part(old_part, part_drop.global_position)

func drop_all_parts(drop_direction: Vector2, drop_force: int) -> void:
	var end_position = global_position + drop_direction.normalized() * drop_force
	
	if head != GHOST_HEAD:
		_spawn_part(head, global_position, end_position)
		head = GHOST_HEAD

	if torso != GHOST_TORSO:
		_spawn_part(torso, global_position, end_position)
		torso = GHOST_TORSO

	if legs != GHOST_LEG:
		_spawn_part(legs, global_position, end_position)
		legs = GHOST_LEG

	_update_parts()

func _spawn_part(part: BasePart, spawn_position: Vector2, end_position: Vector2 = Vector2.ZERO) -> void:
		var part_drop = PART_DROP.instantiate()
		part_drop.part = part
		part_drop.global_position = spawn_position
		
		get_parent().call_deferred("add_child", part_drop)
		part_drop.call_deferred("disable_usebox", 2.0)
		part_drop.call_deferred("animate_spawn", 100)

		if end_position != Vector2.ZERO:
			create_tween().tween_property(part_drop, "global_position", end_position, 1)


func _spawn_bullet(target_position: Vector2) -> void:
	if not torso.bullet:
		Logger.log_debug(self.name, "Can't spawn bullet, no bullet stat")
		return

	if is_shoot_cooldown:
		return

	var bullet = BULLET.instantiate()
	bullet.stat = torso.bullet

	get_parent().add_child(bullet)
	bullet.init_bullet(bullet_spawn.global_position, target_position, Bullet.Type.PLAYER)

	_start_shoot_cooldown(torso.shoot_cooldown)
	shoot_sfx.play()

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
	
func flash(duration: float = 0.1) -> void:
	head_texture.material.set_shader_parameter("active", true)
	torso_texture.material.set_shader_parameter("active", true)
	leg_texture.material.set_shader_parameter("active", true)
	await get_tree().create_timer(duration).timeout
	head_texture.material.set_shader_parameter("active", false)
	torso_texture.material.set_shader_parameter("active", false)
	leg_texture.material.set_shader_parameter("active", false)

func is_player_has_full_set(set_type: Types.SetType) -> bool:
	if head.set_type == set_type and torso.set_type == set_type and legs.set_type == set_type:
		return true

	return false

func _on_regen_timer_timeout() -> void:
	if is_dead:
		return

	if current_health >= torso.max_health:
		return

	_update_health(current_health + torso.regen_amount)
	damage_number.spawn("+%d" % torso.regen_amount, Vector2.UP)
