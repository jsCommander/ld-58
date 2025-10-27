# Utils and Animations

## Log (logger.gd)

- **class**: `Log` extends `RefCounted`
- **flags**: `show_debug: bool`
- **functions**:
  - `log_debug(component_name: String, message: String)`
  - `log_info(component_name: String, message: String)`
  - `log_warn(component_name: String, message: String)`
  - `log_error(component_name: String, message: String)`

Example:
```gdscript
Log.log_info("Player", "Spawned")
Log.log_debug(self.name, "Velocity: %s" % velocity)
```

## Utils (utils.gd)

- **class**: `Utils` extends `RefCounted`
- **functions**:
  - `random_point_in_rect(rect: Rect2) -> Vector2`
  - `get_random_direction() -> Vector2`
  - `get_enum_key_name(_enum, key) -> String`
  - `get_timestamp() -> String`
  - `find_closest_target_in_group(group: String, node: Node2D) -> Node2D`
  - `find_closest_target(targets: Array, node: Node2D) -> Node2D`
  - `get_follow_velocity(node: Node2D, target: Node2D, speed: float, target_offset: float = 5.0) -> Vector2`
  - `deactivate_collider(collider: CollisionShape2D, duration: float) -> void`
  - `get_move_input_vector() -> Vector2`

Example:
```gdscript
var dir = Utils.get_move_input_vector()
if dir != Vector2.ZERO:
  velocity = dir * move_speed
```

## Animations (animations.gd)

- **class**: `Animations` extends `RefCounted`
- **functions**:
  - `pulse(target: CanvasItem, strength:=1.05, duration:=1.0, loop:=true) -> Tween`
  - `shake(target: CanvasItem, intensity:=3.0, duration:=1.0, loop:=false) -> Tween`
  - `fade_in(target: CanvasItem, duration:=1.0) -> Tween`
  - `fade_out(target: CanvasItem, duration:=1.0) -> Tween`
  - `bounce(target: CanvasItem, jump_height:=-10.0, duration:=1.0, loop:=true) -> Tween`
  - `bounce_up(target: CanvasItem, jump_height:=10.0, duration:=1.0) -> Tween`
  - `walk(target: Node2D, sway_angle:=0.1, sway_duration:=0.3, loop:=true) -> Tween`
  - `blink(target: CanvasItem, target_modulate: Color, duration:=0.5, loop:=false) -> Tween`
  - `rotate(target: CanvasItem, rotation_time: float, clockwise:=true, loop:=true) -> Tween`
  - `spawn_arc(target: CanvasItem, end_pos: Vector2, arc_height:=50.0, duration:=1.0) -> Tween`

Example:
```gdscript
await Animations.fade_in($Panel, 0.2).finished
Animations.pulse($Icon, 1.1, 1.0)
```