## LD58 – Game Overview and Developer Guide

This repository contains a small 2D action game built with Godot 4.5. The goal of this README is to help beginners understand the project structure, the main building blocks, and the core systems/classes so you can explore, modify, or extend the game quickly.

### Quick start
- **Requirements**: Godot 4.5 (GL Compatibility) installed.
- **Run in editor**: Open the project folder in Godot and press Play. The entry point is `main.tscn`, which loads the start screen and subsequent levels.
- **Controls**:
  - **Move**: W/A/S/D or Arrow Keys
  - **Shoot**: Left Mouse Button (`action_main`)
  - **Pause**: Escape (`ui_cancel`)
- **Build (Web/Android)**:
  - Web: run `./build_web.sh` to export; `./publish_web.sh` to push the exported build to hosting (adjust for your environment).
  - Android: run `./build_android.sh` (ensure export presets and Android SDK/keystore are set up in Godot).

---

## Project structure
A high-level map of the most important directories and files:

- **`main.tscn`, `main.gd`**: The top-level entry point. `Game` orchestrates scene transitions between start, levels, and end screen.
- **`levels/`**: Scene wrappers for game levels and screens.
  - `base_level.tscn`, `base_level.gd` (class `BaseLevel`) – common level logic (player, camera, dialog, pause).
  - `Level1_final.tscn`, `Level2_final.tscn`, `Level3_final.tscn` – concrete levels.
  - `start_screen/`, `end_screen/` – start and end scenes.
- **`scenes/`**: Gameplay actors and interactables.
  - `player.tscn`, `player.gd` (class `Player`)
  - `base_enemy.tscn`, `base_enemy.gd` (class `BaseEnemy`)
  - `bullet.tscn`, `bullet.gd` (class `Bullet`)
  - `part_drop.tscn`, `part_drop.gd` (class `PartDrop`)
  - `tiles/breakable_wall.gd` (class `BreakableWall`)
  - `dialog_zone.tscn`, `dialog_zone.gd` (class `DialogZone`)
  - `level_finish.tscn`, `level_finish.gd` (class `LevelFinish`)
- **`resources/`**: Game data files (Godot Resources `.tres`) for parts, bullets, enemies, UI.
- **`scripts/`**: Data models (Godot `Resource` classes) and types.
  - `types.gd` (class `Types`) – enums for sets and bullet types.
  - `base_part.gd`, `part_head.gd`, `part_torso.gd`, `part_leg.gd` – equipment parts.
  - `bullet_stat.gd` – bullet properties.
  - `base_enemy_stat.gd` – enemy properties.
- **`game_kit/`**: Reusable framework code (camera, dialogs, base scenes, UI helpers, utils, animations).
  - `scenes/base_game/base_game.gd` (class `BaseGame`) and `base_game_scene.gd` (class `BaseGameScene`)
  - `camera/camera_man.gd` (class `CameraMan`)
  - `dialogs/` (dialog system, including `DialogManager` and conversation resources)
  - `utils/utils.gd`, `utils/animations.gd`, `utils/logger.gd`
- **`data/`**: Dialog JSON files loaded by the conversation system.
- **`assets/`**: Art/audio assets and import metadata.
- **`export_presets.cfg`**, `build_web.sh`, `build_android.sh`, `publish_web.sh` – export configuration and scripts.

---

## Main building blocks
The game is split into a few foundational building blocks. Understanding these will make the rest of the codebase click.

- **Scene flow (Game/Level framework)**
  - `Game` (`main.gd`, extends `BaseGame`) owns the global scene flow and fade transitions. It loads the Start Screen, then Level 1 → Level 2 → Level 3 → End Screen, then loops back to Start.
  - `BaseGame` handles transitioning between scenes with a fade animation and wires signals for scene completion/reload.
  - `BaseGameScene` is a base class for any playable screen that can emit `finished(data)` or `reload_requested(data)`.
  - `BaseLevel` adds player/camera/dialog setup, pause dialog, and level finish handling.

- **Actors and combat**
  - `Player` (`CharacterBody2D`): Movement, shooting, health/invulnerability, and picking up equipment parts.
  - `BaseEnemy` (`CharacterBody2D`): Enemy AI state machine (Idle, Attack, Evade, Love Player), taking damage, dropping parts, optional ranged attacks.
  - `Bullet` (`CharacterBody2D`): Moves in a direction, applies damage and knockback on hit, despawns after max range.
  - `BreakableWall` (`Node2D`): Can be destroyed only by a specific bullet type.

- **Equipment and stats**
  - Parts: `PartHead`, `PartTorso`, `PartLeg` (all extend `BasePart`). Torso configures bullet type/cooldown and max health; legs define movement speed; head selects set visuals.
  - Stats resources: `BulletStat` (damage, speed, range, type), `BaseEnemyStat` (HP, movement, agro timings, bullet, etc.).
  - `Types` defines `SetType` (BUNNY, DEMON, PUMKIN, GHOST) and `BulletType` (CARROT, PUMPKIN_SEED, FIREBALL).

- **Dialog system**
  - `DialogZone` emits an event when the player enters; it provides a `Conversation` that reads lines from a JSON file in `data/`.
  - `DialogManager` shows modal dialogs (e.g., conversations, pause dialog) and can pause/unpause the game while open.
  - Conversation content and speakers are data-driven (via resources and JSON).

- **Camera and presentation**
  - `CameraMan` follows the player, can arrive to a point, zoom smoothly, and shake.
  - `BaseRig` provides common visuals and tween-based walk/pulse/flash helpers for characters.
  - `Animations` offers reusable tweens (fade in/out, pulse, shake, walk, bounce, arc, etc.).

- **Utilities and logging**
  - `Utils` gathers common helpers (movement input vector, randoms, enum name lookups, collider timing, follow velocity).
  - `Log` provides consistent timestamped logging (`Log.log_debug/info/warn/error`).

---

## Core systems and how they work

### 1) Scene flow and transitions
- **Files**: `main.gd` (`Game`), `game_kit/scenes/base_game/base_game.gd` (`BaseGame`), `game_kit/scenes/base_game/base_game_scene.gd` (`BaseGameScene`).
- **Idea**:
  - `Game` defines a map of scene transitions (Start → Level1 → Level2 → Level3 → End → Start) and calls `load_scene(...)` on `BaseGame`.
  - `BaseGame` plays a fade-in/fade-out animation via a `CanvasLayer`, removes the previous scene, instantiates the next one, and wires `finished` / `reload_requested` signals if it’s a `BaseGameScene`.
  - Levels call `finished.emit({})` to advance, or `reload_requested.emit(data)` to reload (e.g., when the player dies).

### 2) Level orchestration
- **Files**: `levels/base_level.gd` (`BaseLevel`).
- **Key responsibilities**:
  - Connects to `Player.killed` → requests reload with state (`visited_dialog_zones`) preserved.
  - Connects `DialogZone.player_entered` → opens conversation dialog via `DialogManager`.
  - Connects `LevelFinish.player_entered` → emits `finished({})` for `BaseGame` to load the next scene.
  - Initializes `CameraMan` follow and default zoom.
  - Handles pause via `DialogManager` when Escape is pressed.

### 3) Player
- **Files**: `scenes/player.gd`.
- **Highlights**:
  - Movement uses `Utils.get_move_input_vector()` and legs’ `speed`.
  - Shooting spawns `Bullet` using the torso’s `bullet` stat and `shoot_cooldown`.
  - Health UI updates; invulnerability window disables the hurtbox collider.
  - Picking up `PartDrop` swaps equipment, spawns the replaced part with a nice arc/pulse animation, and remembers last pickup positions.

### 4) Enemies and AI
- **Files**: `scenes/base_enemy.gd`, `scripts/base_enemy_stat.gd`.
- **Highlights**:
  - State machine: `IDLE`, `ATTAK_PLAYER`, `EVADE`, `LOVE_PLAYER`.
    - If the player wears a full set matching the enemy’s `stat.type`, the enemy shows a heart (love) and doesn’t attack.
    - Otherwise: may move toward the player and/or shoot depending on `stat.can_move` and `stat.bullet`.
    - Evades back to an anchor if too far from its spawn or after agro timeout.
  - On damage: shows numbers, plays SFX, optional knockback, may switch to attack state.
  - On death: optionally spawns a `PartDrop` and despawns after SFX.

### 5) Bullets and damage
- **Files**: `scenes/bullet.gd`, `scripts/bullet_stat.gd`, `scenes/tiles/breakable_wall.gd`.
- **Highlights**:
  - Bullets move until they exceed `attack_range` or hit something.
  - Apply damage/knockback to `Player` or `BaseEnemy` depending on bullet `type` (PLAYER or ENEMY).
  - `BreakableWall` only breaks if hit by `Types.BulletType.FIREBALL`.

### 6) Equipment and sets
- **Files**: `scripts/base_part.gd`, `scripts/part_head.gd`, `scripts/part_torso.gd`, `scripts/part_leg.gd`, `scenes/part_drop.gd`, `scripts/types.gd`.
- **Highlights**:
  - Parts are simple `Resource`s with visuals and set type; Torso also configures bullet stats and health properties; Legs set movement speed.
  - Wearing a full matching set (`Types.SetType`) affects enemy behavior (some will love, not attack).
  - Dropped parts (`PartDrop`) pulse in the world, can disable their pickup collider for a bit, and animate into view.

### 7) Dialogs
- **Files**: `scenes/dialog_zone.gd`, `game_kit/dialogs/dialog_manager/dialog_manager.gd`, `game_kit/dialogs/dialog_manager/base_dialog.gd`, `game_kit/dialogs/dialog_conversation/*.gd`, `data/*.json`.
- **Highlights**:
  - `DialogZone` signals when the player enters; it provides a `Conversation` that loads and parses a JSON lines array from `data/`.
  - `DialogManager.open_dialog(...)` displays a modal dialog scene, optionally pausing the game, and returns a `finished` signal you can `await`.
  - JSON is validated to ensure speakers exist; speakers are defined via resources.

### 8) Camera and presentation
- **Files**: `game_kit/camera/camera_man.gd`, `game_kit/scenes/base_rig/base_rig.gd`, `game_kit/utils/animations.gd`.
- **Highlights**:
  - `CameraMan` supports follow, arrive-to-point, zoom, and shake with smooth interpolation.
  - `BaseRig` centralizes character visuals (walk sway, pulse, flash) using `Animations` tweens.
  - `Animations` provides composable helpers: `fade_in/out`, `pulse`, `shake`, `walk`, `bounce_up`, `spawn_arc`, `blink`, `rotate`.

### 9) Utilities and logging
- **Files**: `game_kit/utils/utils.gd`, `game_kit/utils/logger.gd`.
- **Highlights**:
  - `Utils` contains generic helpers – favor using these rather than duplicating logic.
  - `Log.log_debug(self.name, message)` is used throughout for important actions.

---

## How to extend the game

### Add a new enemy
1. Create a new `BaseEnemyStat` resource (`.tres`) under `resources/enemy/` with texture, HP, movement, agro values, optional bullet stat, sounds, etc.
2. Duplicate an existing enemy scene from `scenes/` and assign your new stat resource.
3. Place the enemy instance into a level scene under `levels/`.

### Add a new bullet type
1. Create a `BulletStat` resource with texture, speed, damage, range, knockback, and set the `Types.BulletType`.
2. Assign that bullet stat to a Torso part (see below), or to an enemy’s stat if it should shoot it.

### Add a new player part
1. Duplicate a part resource (`PartHead`, `PartTorso`, or `PartLeg`) in `resources/parts/`.
2. Set its texture and `Types.SetType`.
3. For torso: also set `bullet`, `shoot_cooldown`, `max_health`, and regen.
4. Drop parts can be spawned by enemies (`BaseEnemy.drop_part`) or placed in levels as `PartDrop`.

### Add dialog
1. Create a JSON file in `data/` with an array of lines: `[ { "speaker_id": "npc", "text": "Hello!" }, ... ]`.
2. Create or update a speaker array resource to include the speakers.
3. Add a `DialogZone` to a level and set its `json_file` and `speakers` in the Inspector.

---

## Conventions and notes
- **Groups**: `player`, `dialog_zone`, `level_finish` are used for signal wiring and lookups.
- **Physics layers**: see `project.godot` for named 2D physics layers; keep collisions consistent with existing layers.
- **Input map**: `move_left/right/up/down`, `action_main`, `action_secondary`, `ui_cancel` in `project.godot`.
- **Logging**: use `Log.log_debug(self.name, message)` for important actions.
- **Animations**: prefer helpers in `game_kit/utils/animations.gd`.
- **Utilities**: prefer helpers in `game_kit/utils/utils.gd`.

---

## Reference: Key classes at a glance
- **Game flow**: `Game` → `BaseGame` → `BaseGameScene` → `BaseLevel`
- **Player**: `Player` + parts (`PartHead`, `PartTorso`, `PartLeg`) + `PartDrop`
- **Enemies**: `BaseEnemy` + `BaseEnemyStat`
- **Projectiles**: `Bullet` + `BulletStat` + `Types.BulletType`
- **Environment**: `BreakableWall`
- **Dialogs**: `DialogZone`, `DialogManager`, `BaseDialog`, `Conversation` (+ JSON in `data/`)
- **Camera/Visuals**: `CameraMan`, `BaseRig`, `Animations`
- **Common**: `Utils`, `Log`, `Types`

If you’re new to Godot, a helpful entry path is: open `main.tscn` → inspect `levels/base_level.tscn` → open `scenes/player.tscn` and `scenes/base_enemy.tscn` → review the resources under `resources/`.
