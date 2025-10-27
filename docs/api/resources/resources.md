# Resources and Data Models

## Types (scripts/types.gd)
- **enums**:
  - `SetType`: `BUNNY, DEMON, PUMKIN, GHOST`
  - `BulletType`: `CARROT, PUMPKIN_SEED, FIREBALL`

## Parts
- **BasePart**: `texture: Texture2D`, `set_type: Types.SetType`
- **PartHead**: extends `BasePart`
- **PartTorso**: extends `BasePart`; `bullet: BulletStat`, `shoot_cooldown: float`, `max_health: int`, `invulnebility_time: float`, `regen_amount: int`
- **PartLeg**: extends `BasePart`; `speed: int`

## Combat Stats
- **BulletStat**: `type: Types.BulletType`, `texture: Texture2D`, `speed: int`, `damage: int`, `attack_range: int`, `knockback_force: int`
- **BaseEnemyStat**: texture, love_sound, type, health/damage/speed/knockback; AI: `can_move`, `agro_*`, `evade_speed`; ranged: `bullet`, `shoot_cooldown`

## UI Theme (UiTheme)
- Color tokens: `background, card, overlay, text, text_inverse, text_muted, accent, accent_hover, accent_active, success, danger, border, progress_bar, progress_bar_bg`

