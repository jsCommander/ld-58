extends CharacterBody2D
class_name BaseEnemy

@export var stat: BaseEnemyStat

@onready var base_rig: BaseRig = $BaseRig
@onready var hitbox: Area2D = $Hitbox
@onready var health_bar: ProgressBar = %HealthBar

var current_health: int = 0
var is_dead: bool = false

func _ready() -> void:
	_update_health(stat.max_health)

func kill() -> void:
	if is_dead:
		return

	is_dead = true
	queue_free()

func apply_damage(damage: int, _attacker: Node2D) -> void:
	if is_dead:
		return

	Logger.log_debug(self.name, "Applied damage: %s from %s" % [damage, _attacker.name])
	_update_health(current_health - damage)

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
		player.apply_damage(stat.damage, self)
