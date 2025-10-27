# Actors and Gameplay Scenes

## Player (scenes/player.gd)
- **class**: `Player` extends `CharacterBody2D`
- **exports**: `head: PartHead`, `torso: PartTorso`, `legs: PartLeg`
- **signals**: `killed()`
- **key methods**:
  - `apply_damage(damage: int, attacker: Node2D, knockback_force := 0)`
  - `kill()`
  - `reset_parts_to_default()`
  - `is_player_has_full_set(set_type: Types.SetType) -> bool`

Example:
```gdscript
$Player.apply_damage(10, self)
if $Player.is_player_has_full_set(Types.SetType.GHOST):
  print("Full set!")
```

## BaseEnemy (scenes/base_enemy.gd)
- **class**: `BaseEnemy` extends `CharacterBody2D`
- **exports**: `stat: BaseEnemyStat`, `drop_part: BasePart`
- **key methods**:
  - `apply_damage(damage: int, attacker: Node2D, knockback_force := 0)`
  - `kill()`
- **states**: `IDLE`, `LOVE_PLAYER`, `ATTAK_PLAYER`, `EVADE`

Example damage application:
```gdscript
enemy.apply_damage(15, $Player, 2)
```

## Bullet (scenes/bullet.gd)
- **class**: `Bullet` extends `CharacterBody2D`
- **exports**: `stat: BulletStat`, `type: Bullet.Type`
- **signals**: `hit(target: Node2D, bullet: Bullet)`
- **methods**:
  - `init_bullet(spawn: Vector2, target: Vector2, type: Bullet.Type)`
  - `kill()`
  - `update_bullet_texture()`

Example:
```gdscript
var b := preload("res://scenes/bullet.tscn").instantiate()
b.stat = preload("res://resources/bullets/carrot.tres")
add_child(b)
b.init_bullet($Marker.global_position, get_global_mouse_position(), Bullet.Type.PLAYER)
```

## ThinkBubble (game_kit/scenes/think_bubble.gd)
- `show_bubble(icon: Texture2D, duration := 0.0)` fades in/out when duration > 0.

## DamageNumber (game_kit/scenes/damage_number.gd)
- `spawn(damage: String, direction: Vector2)` spawns animated floating label.

## PartDrop (scenes/part_drop.gd)
- **exports**: `part: BasePart`
- **methods**: `kill()`, `disable_usebox(duration:=0.0)`, `enable_usebox()`, `animate_spawn(height:=100.0)`

## PartDropZone (scenes/part_drop_zone.gd)
- Resets player parts to defaults when entered.

## BreakableWall (scenes/tiles/breakable_wall.gd)
- **exports**: `max_health: int`
- **methods**: `apply_damage(damage: int, bullet_type: Types.BulletType)`

## DialogZone (scenes/dialog_zone.gd)
- **exports**: `speakers: ConversationSpeakerArray`, `json_file: String`
- **signals**: `player_entered(json_file: String, conversation: Conversation)`

## LevelFinish (scenes/level_finish.gd)
- **signals**: `player_entered()`
