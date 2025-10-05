extends Node2D

@export var damage: int = 5
@export var knockback_force: int = 50

func _on_hitbox_area_entered(area: Area2D) -> void:
	var body = area.get_parent()

	if body is BaseEnemy:
		var enemy = body as BaseEnemy
		if enemy.type != Types.SetType.PUMKIN:
			enemy.apply_damage(damage, self, knockback_force)

	if body is Player:
		var player = body as Player
		if player.legs.set_type != Types.SetType.PUMKIN:
			player.apply_damage(damage, self, knockback_force)
