extends CharacterBody2D
class_name Bullet

enum Type {
	PLAYER,
	ENEMY
}

@export var stat: BulletStat
@export var type: Type = Type.PLAYER

signal hit(target: Node2D, bullet: Bullet)

@onready var bullet_texture: Sprite2D = %BulletTexture
@onready var hitbox: Area2D = %Hitbox

var spawn_position: Vector2
var fly_direction: Vector2

func _ready() -> void:
	update_bullet_texture()
	Logger.log_debug(self.name, "Bullet spawned")
	Animations.fade_in(self, 0.3)
	Animations.shake(bullet_texture, 10, 0.4, true)

func _physics_process(_delta: float) -> void:
	if not fly_direction:
		return

	velocity = fly_direction.normalized() * stat.speed
	
	var distance_to_spawn = global_position.distance_to(spawn_position)

	if distance_to_spawn > stat.attack_range:
		kill()

	move_and_slide()

func init_bullet(_spawn_position: Vector2, _target_position: Vector2, _type: Type) -> void:
	type = _type
	spawn_position = _spawn_position
	fly_direction = spawn_position.direction_to(_target_position)
	global_position = _spawn_position
	bullet_texture.rotation = -fly_direction.angle_to(Vector2.RIGHT)
	

func kill() -> void:
	Logger.log_debug(self.name, "Bullet killed")
	queue_free()

func update_bullet_texture() -> void:
	if bullet_texture.texture != stat.texture:
		bullet_texture.texture = stat.texture


func _on_hitbox_area_entered(area: Area2D) -> void:
	var body = area.get_parent()

	if body is BaseEnemy and type == Type.PLAYER:
		var enemy = body as BaseEnemy
		enemy.apply_damage(stat.damage, self, stat.knockback_force)
		kill()
		hit.emit(enemy, self)

	if body is Player and type == Type.ENEMY:
		var player = body as Player
		player.apply_damage(stat.damage, self, stat.knockback_force)
		kill()
		hit.emit(player, self)

	if body is BreakableWall:
		var wall = body as BreakableWall
		wall.apply_damage(stat.damage, stat.type)
		kill()
		hit.emit(wall, self)
