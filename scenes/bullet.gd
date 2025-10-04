extends CharacterBody2D
class_name Bullet

@export var stat: BulletStat

@onready var base_rig: BaseRig = $BaseRig
@onready var bullet_texture: Sprite2D = %BulletTexture

var spawn_position: Vector2
var fly_direction: Vector2

func _ready() -> void:
	base_rig.start_pulse_animation()
	update_bullet_texture()
	Logger.log_debug(self.name, "Bullet spawned")

func _physics_process(delta: float) -> void:
	if not fly_direction:
		return

	velocity = fly_direction.normalized() * stat.speed
	
	var distance_to_spawn = global_position.distance_to(spawn_position)

	if distance_to_spawn > stat.range:
		kill()

	move_and_slide()

func init_bullet(_spawn_position: Vector2, _fly_direction: Vector2) -> void:
	spawn_position = _spawn_position
	fly_direction = _fly_direction
	global_position = _spawn_position

func kill() -> void:
	Logger.log_debug(self.name, "Bullet killed")
	queue_free()

func update_bullet_texture() -> void:
	if bullet_texture.texture != stat.texture:
		bullet_texture.texture = stat.texture
