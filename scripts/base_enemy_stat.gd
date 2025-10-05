extends Resource
class_name BaseEnemyStat

@export var texture: Texture2D
@export var type: Types.SetType = Types.SetType.GHOST

@export var max_health: int = 100
@export var health_regen: int = 5

@export var damage: int = 10
@export var speed: int = 400
@export var knockback_force: int = 100
@export var can_move = false

@export var agro_time: float = 2.0
@export var agro_time_after_hurt: float = 5.0
@export var agro_range: int = 600
@export var agro_max_distance: int = 500
@export var evade_speed: float = 600

@export var bullet: BulletStat
@export var shoot_cooldown: float = 0.5
