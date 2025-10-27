# Game Flow APIs

## BaseGame (game_kit/scenes/base_game/base_game.gd)
- **class**: `BaseGame` extends `Node`
- **exports**:
  - `transition_time: float = 0.1`
- **onready**:
  - `scene_root: Node2D`
  - `animation_player: AnimationPlayer`
  - `canvas_layer: CanvasLayer`
- **vars**: `current_scene: PackedScene`, `current_scene_instance: Node`
- **functions**:
  - `_ready()`
  - `load_scene(scene: PackedScene, data: Dictionary = {})`
  - `handle_scene_finished(_data: Dictionary)`
  - `handle_scene_reload_requested(_data: Dictionary)`
  - `_start_transition()` / `_end_transition()`

Example:
```gdscript
# Inheriting game
extends BaseGame
func _ready():
  super._ready()
  load_scene(preload("res://levels/start_screen/start_screen.tscn"))
```

## BaseGameScene (game_kit/scenes/base_game/base_game_scene.gd)
- **class**: `BaseGameScene` extends `Node`
- **exports**:
  - `data: Dictionary = {}`
- **signals**:
  - `finished(_data: Dictionary)`
  - `reload_requested(data: Dictionary)`
- **functions**:
  - `_ready()`
  - `set_data(_data: Dictionary)`

Example:
```gdscript
extends BaseGameScene
func _ready():
  super._ready()
  finished.emit({})
```

## Game (main.gd)
- **class**: `Game` extends `BaseGame`
- **constants**: `SCENE_TRANSITIONS: Dictionary[PackedScene, PackedScene]`
- **functions**:
  - `_ready()` calls `load_scene(START_SCREEN)`
  - `handle_scene_finished(_data: Dictionary)` loads next scene

Usage:
```gdscript
# Game autoload or root scene uses Game
```