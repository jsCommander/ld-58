extends CharacterBody2D
class_name BaseEnemy

@export var stat: BaseEnemyStat

@onready var base_rig: BaseRig = $BaseRig
@onready var hitbox: Area2D = $Hitbox
@onready var health_bar: ProgressBar = %HealthBar
@onready var damage_number: DamageNumber = $DamageNumber
@onready var hit_sfx: AudioStreamPlayer2D = %HitSfx
@onready var think_buble: ThinkBubble = %ThinkBuble
@onready var death_sfx: AudioStreamPlayer2D = %DeathSfx
@onready var hurtbox_collider: CollisionShape2D = %HurtboxCollider
@onready var hitbox_collider: CollisionShape2D = %HitboxCollider

var current_health: int = 0
var is_dead: bool = false

func _ready() -> void:
	_update_health(stat.max_health)

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

	if knockback_force > 0.0:
		var knockback_velocity = attack_direction * knockback_force * 100
		velocity = knockback_velocity
		move_and_slide()


func _update_health(health: int) -> void:
	current_health = clamp(health, 0, stat.max_health)

	health_bar.value = current_health
	health_bar.max_value = stat.max_health
	
	if current_health <= 0:
		kill()


func _on_hitbox_area_entered(area: Area2D) -> void:
	var body = area.get_parent()

	if body is Player:
		var player = body as Player
		player.apply_damage(stat.damage, self, stat.knockback_force)
