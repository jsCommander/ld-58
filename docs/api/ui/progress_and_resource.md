# UI Progress and Resource Count

## UiProgressBar
- **class**: `UiProgressBar` extends `Control`
- **exports**:
  - `max_value: float`
  - `value: float`
- **functions**:
  - `_update()`

Example:
```gdscript
$UiProgressBar.max_value = 100
$UiProgressBar.value = 55
```

## UiResourceCount
- **class**: `UiResourceCount` extends `Control`
- **exports**:
  - `count: int`
  - `icon: Texture2D`

Example:
```gdscript
$UiResourceCount.count = 3
$UiResourceCount.icon = preload("res://game_kit/assets/icons/icn_heart.png")
```