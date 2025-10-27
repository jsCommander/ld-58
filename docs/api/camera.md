# CameraMan (game_kit/camera/camera_man.gd)

- **class**: `CameraMan` extends `Camera2D`
- **exports**:
  - `smoothing: float = 2.5`
  - `follow_target_offset: Vector2 = Vector2.ZERO`
  - `arrive_point_min_distance: float = 5.0`
- **modes**: `IDLE`, `FOLLOW_TARGET`, `ARRIVE_TO_POINT`
- **functions**:
  - `follow_target(target: Node2D)`
  - `arrive_to_point(point: Vector2)`
  - `set_idle()`
  - `shake(intensity: float = -1, duration: float = -1)`
  - `zoom_to(target_zoom: float, duration: float = 1.0)`

Example:
```gdscript
$CameraMan.follow_target($Player)
$CameraMan.zoom_to(0.8, 0.5)
$CameraMan.shake(8, 0.3)
```