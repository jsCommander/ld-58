extends Node2D
class_name BreakableWall

@export var max_health: int = 40

@onready var collision_shape_2d: CollisionShape2D = %CollisionShape2D
@onready var sprite_2d: Sprite2D = %Sprite2D
@onready var damage_number: DamageNumber = $DamageNumber
@onready var hit_sfx: AudioStreamPlayer2D = %HitSfx

var current_health: int = 0

func _ready() -> void:
	current_health = max_health

func apply_damage(damage: int, bullet_type: Types.BulletType) -> void:
	if bullet_type != Types.BulletType.FIREBALL:
		return

	_flash()
	
	var damage_to_apply = clamp(damage, 0, current_health)
	current_health -= damage_to_apply

	damage_number.spawn("-%d" % damage_to_apply, Vector2.UP)
	hit_sfx.play()
	await hit_sfx.finished

	if current_health <= 0:
		queue_free()


func _flash() -> void:
	sprite_2d.material.set_shader_parameter("active", true)
	await get_tree().create_timer(0.1).timeout
	sprite_2d.material.set_shader_parameter("active", false)
