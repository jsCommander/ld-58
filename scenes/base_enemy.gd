@tool
extends CharacterBody2D
class_name BaseEnemy

const PART_DROP = preload("res://scenes/part_drop.tscn")
const ICN_ANGER = preload("res://game_kit/assets/icons/icn_anger.png")
const BULLET = preload("res://scenes/bullet.tscn")

enum State {
	IDLE,
	SHOOT
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

var current_health: int = 0
var is_dead: bool = false
var is_shoot_cooldown: bool = false

var current_state: State = State.IDLE
var player: Player

func _ready() -> void:
	_update_health(stat.max_health)
	_update_texture()
	_set_state(State.IDLE)

func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint():
		_update_texture()
		return
	
	if is_dead:
		return

	match current_state:
		State.IDLE:
			if not is_instance_valid(player):
				player = _find_player()
			
			if not player:
				return
				
			if stat.bullet:
				var distance_to_player = global_position.distance_to(player.global_position)

				if distance_to_player <= stat.agro_shoot_range:
					_set_state(State.SHOOT)
			
		State.SHOOT:
			if is_shoot_cooldown:
				return

			_spawn_bullet(player.global_position)

func kill() -> void:
	if is_dead:
		return

	is_dead = true
	base_rig.visible = false

	hurtbox_collider.set_deferred("disabled", true)
	hitbox_collider.set_deferred("disabled", true)
	
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
	
	var attack_direction = attacker.global_position.direction_to(global_position)

	_set_agro()

	if knockback_force > 0.0:
		var knockback_velocity = attack_direction * knockback_force * 100
		velocity = knockback_velocity
		move_and_slide()

func _set_agro() -> void:
	if current_state == State.SHOOT:
		agro_time.start()
		return

	if stat.bullet and current_state != State.SHOOT:
		_set_state(State.SHOOT)
		return


func _update_texture() -> void:
	if body.texture != stat.texture:
		body.texture = stat.texture

func _spawn_drop_part(part: BasePart, spawn_position: Vector2) -> void:
		var drop: PartDrop = PART_DROP.instantiate()
		drop.part = part
		drop.global_position = spawn_position
		
		get_parent().call_deferred("add_child", drop)
		drop.call_deferred("disable_usebox", 2.0)

		drop.call_deferred("animate_spawn", 100)

		create_tween().tween_property(drop, "global_position", spawn_position, 1)

func _update_health(health: int) -> void:
	current_health = clamp(health, 0, stat.max_health)

	health_bar.value = current_health
	health_bar.max_value = stat.max_health
	
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
	
func _set_state(new_state: State) -> void:
	if current_state == new_state:
		return

	var old_state = current_state
	current_state = new_state

	Logger.log_debug(self.name, "Changing state from %s to %s" % [Utils.get_enum_key_name(State, old_state), Utils.get_enum_key_name(State, new_state)])

	match new_state:
		State.IDLE:
			agro_time.stop()
			think_buble.visible = false
		
		State.SHOOT:
			think_buble.visible = true
			think_buble.show_bubble(ICN_ANGER)
			agro_time.wait_time = stat.agro_time
			agro_time.start()

func _start_shoot_cooldown(cooldown: float) -> void:
	is_shoot_cooldown = true
	await get_tree().create_timer(cooldown).timeout
	is_shoot_cooldown = false

func _spawn_bullet(target_position: Vector2) -> void:
	var bullet = BULLET.instantiate()
	bullet.stat = stat.bullet

	get_parent().add_child(bullet)
	bullet.init_bullet(bullet_spawn.global_position, target_position, Bullet.Type.ENEMY)

	bullet.hit.connect(func(_target: Node2D, _bullet: Bullet):
		_set_agro()
	)

	_start_shoot_cooldown(stat.shoot_cooldown)

func _on_agro_time_timeout() -> void:
	if current_state == State.SHOOT:
		_set_state(State.IDLE)
