@tool
extends CharacterBody2D
class_name BaseEnemy

const PART_DROP = preload("res://scenes/part_drop.tscn")
const ICN_ANGER = preload("res://game_kit/assets/icons/icn_anger.png")
const BULLET = preload("res://scenes/bullet.tscn")
const ICN_HEART = preload("res://game_kit/assets/icons/icn_heart.png")

enum State {
	IDLE,
	LOVE_PLAYER,
	ATTAK_PLAYER,
	EVADE,
}

@export var stat: BaseEnemyStat
@export var drop_part: BasePart

@onready var base_rig: BaseRig = $BaseRig
@onready var hitbox: Area2D = $Hitbox
@onready var health_bar: ProgressBar = %HealthBar
@onready var damage_number: DamageNumber = $DamageNumber
@onready var hit_sfx: AudioStreamPlayer2D = %HitSfx
@onready var think_buble: ThinkBubble = %ThinkBuble
@onready var death_sfx: AudioStreamPlayer2D = %DeathSfx
@onready var hurtbox_collider: CollisionShape2D = %HurtboxCollider
@onready var hitbox_collider: CollisionShape2D = %HitboxCollider
@onready var body: Sprite2D = $BaseRig/AnimationRig/Body
@onready var agro_time: Timer = %AgroTime
@onready var bullet_spawn: Marker2D = %BulletSpawn
@onready var regen_timer: Timer = %RegenTimer
@onready var love_sfx: AudioStreamPlayer2D = %LoveSfx
@onready var shoot_sfx: AudioStreamPlayer2D = %ShootSfx

var current_health: int = 0
var is_dead: bool = false
var is_shoot_cooldown: bool = false

var current_state: State = State.IDLE
var player: Player

var evade_position: Vector2

func _ready() -> void:
	_update_health(stat.max_health)
	_update_texture()
	# spawn position is evade anchor
	evade_position = global_position
	_set_state(State.IDLE)

func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint():
		_update_texture()
		return
	
	if is_dead:
		return

	if not is_instance_valid(player):
		player = _find_player()
			
	if not player:
		return

	var distance_to_player = global_position.distance_to(player.global_position)
	var is_player_in_agro_zone = distance_to_player <= stat.agro_range

	match current_state:
		State.IDLE:
			velocity = Vector2.ZERO

			if is_player_in_agro_zone:
				if player.is_player_has_full_set(stat.type):
					_set_state(State.LOVE_PLAYER)
				elif stat.bullet or stat.can_move:
					_set_state(State.ATTAK_PLAYER)
			
		State.ATTAK_PLAYER:
			# evade if too far from evade position
			var distance_to_evade_position = global_position.distance_to(evade_position)
			# var shoot_distance = stat.bullet.attack_range if stat.bullet else 0

			if stat.can_move and distance_to_evade_position > stat.agro_max_distance:
				_set_state(State.EVADE)
			# elif !stat.can_move and stat.bullet and shoot_distance < distance_to_player:
			# 	_set_state(State.IDLE)
			# move to player
			elif stat.can_move:
				var move_direction = global_position.direction_to(player.global_position)
				velocity = move_direction * stat.speed

				# stop following if can shoot and player too close
				if stat.bullet and distance_to_player < stat.agro_range:
					velocity = Vector2.ZERO

			#  if can shoot than shoot
			if stat.bullet and not is_shoot_cooldown:
				_spawn_bullet(player.global_position)

		State.LOVE_PLAYER:
			if not is_player_in_agro_zone:
				_set_state(State.IDLE)

			elif not player.is_player_has_full_set(stat.type):
				_set_state(State.IDLE)

		State.EVADE:
			var distance_to_evade_position = global_position.distance_to(evade_position)

			if distance_to_evade_position <= 10:
				_set_state(State.IDLE)
			else:
				var move_direction = global_position.direction_to(evade_position)
				velocity = move_direction * stat.evade_speed
				
	base_rig.update_walk_animation(velocity)
	move_and_slide()

func kill() -> void:
	if is_dead:
		return

	is_dead = true
	base_rig.visible = false

	hurtbox_collider.set_deferred("disabled", true)
	hitbox_collider.set_deferred("disabled", true)
	
	if drop_part:
		_spawn_drop_part(drop_part, global_position)
	
	death_sfx.play()
	await death_sfx.finished
	queue_free()

func apply_damage(damage: int, attacker: Node2D, knockback_force: int = 0) -> void:
	if is_dead:
		return

	base_rig.flash()
	hit_sfx.play()

	var damage_to_apply = clamp(damage, 0, current_health)
	_update_health(current_health - damage_to_apply)
	damage_number.spawn("-%d" % damage_to_apply, Vector2.UP)
	
	var attack_direction = attacker.global_position.direction_to(global_position).normalized()

	_set_agro()

	if knockback_force > 0.0:
		var knockback_velocity = attack_direction * knockback_force * 100
		var old_velocity = velocity
		velocity = knockback_velocity
		move_and_slide()
		velocity = old_velocity

func _set_agro() -> void:
	# do nothing if can't move and can't shoot
	if not stat.can_move and not stat.bullet:
		return

	if current_state == State.ATTAK_PLAYER:
		agro_time.start()
		return

	var can_attack = stat.bullet or stat.can_move

	if can_attack and current_state != State.ATTAK_PLAYER:
		_set_state(State.ATTAK_PLAYER, {"agro_time": stat.agro_time_after_hurt})
		return

func _update_texture() -> void:
	if body.texture != stat.texture:
		body.texture = stat.texture

func _spawn_drop_part(part: BasePart, spawn_position: Vector2) -> void:
		var drop: PartDrop = PART_DROP.instantiate()
		drop.part = part
		drop.global_position = spawn_position
		
		get_parent().call_deferred("add_child", drop)
		drop.call_deferred("disable_usebox", 1.0)

		drop.call_deferred("animate_spawn", 100)

		create_tween().tween_property(drop, "global_position", spawn_position, 1)

func _update_health(health: int) -> void:
	current_health = clamp(health, 0, stat.max_health)

	health_bar.max_value = stat.max_health
	health_bar.value = current_health
	
	if current_health <= 0:
		kill()

func _on_hitbox_area_entered(area: Area2D) -> void:
	var _body = area.get_parent()

	if _body is Player:
		var _player = _body as Player
		_player.apply_damage(stat.damage, self, stat.knockback_force)

func _find_player() -> Player:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0 and players[0] is Player:
		return players[0]
	
	return null
	
func _set_state(new_state: State, data: Dictionary = {}) -> void:
	if current_state == new_state:
		return

	var old_state = current_state
	current_state = new_state

	Logger.log_debug(self.name, "Changing state from %s to %s" % [Utils.get_enum_key_name(State, old_state), Utils.get_enum_key_name(State, new_state)])

	match old_state:
		State.IDLE:
			regen_timer.stop()

		State.ATTAK_PLAYER:
			agro_time.stop()
			think_buble.visible = false

		State.LOVE_PLAYER:
			think_buble.visible = false

	match new_state:
		State.IDLE:
			agro_time.stop()
			regen_timer.start()
			think_buble.visible = false
		
		State.ATTAK_PLAYER:
			think_buble.visible = true
			think_buble.show_bubble(ICN_ANGER)
			agro_time.wait_time = data.agro_time if data.has("agro_time") else stat.agro_time
			agro_time.start()

		State.LOVE_PLAYER:
			think_buble.visible = true
			think_buble.show_bubble(ICN_HEART)
			love_sfx.play()

func _start_shoot_cooldown(cooldown: float) -> void:
	is_shoot_cooldown = true
	await get_tree().create_timer(cooldown).timeout
	is_shoot_cooldown = false

func _spawn_bullet(target_position: Vector2) -> void:
	var bullet = BULLET.instantiate()
	bullet.stat = stat.bullet

	get_parent().add_child(bullet)
	bullet.init_bullet(bullet_spawn.global_position, target_position, Bullet.Type.ENEMY)

	shoot_sfx.play()
	_start_shoot_cooldown(stat.shoot_cooldown)

func _on_agro_time_timeout() -> void:
	if current_state != State.ATTAK_PLAYER:
		return

	var distance_to_player = global_position.distance_to(player.global_position)

	if distance_to_player <= stat.agro_range:
		agro_time.start()
		return

	if stat.can_move:
		_set_state(State.EVADE)
	else:
		_set_state(State.IDLE)

func _on_regen_timer_timeout() -> void:
	if current_state == State.IDLE:
		_update_health(current_health + stat.health_regen)
