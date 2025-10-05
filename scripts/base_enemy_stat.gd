extends Resource
class_name BaseEnemyStat

@export var texture: Texture2D

@export var max_health: int = 100
@export var damage: int = 10
@export var speed: int = 400
@export var knockback_force: int = 100
@export var can_move = false

@export var bullet: BulletStat
@export var shoot_cooldown: float = 0.5
@export var agro_shoot_range: int = 600


@export var agro_time: float = 2.0
