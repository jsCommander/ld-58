# Scene Usage Examples

## Loading Scenes with BaseGame
```gdscript
extends BaseGame
func _ready():
  super._ready()
  var level := preload("res://levels/Level1_final.tscn")
  load_scene(level, {"visited_dialog_zones": []})
```

## Opening a Conversation Dialog
```gdscript
var conv := Conversation.new()
conv.speakers = preload("res://resources/speakers.tres")
conv.json_file = "res://data/dialog_json/lvl1start.json"
var finished_signal := $DialogManager.open_dialog(
  preload("res://game_kit/dialogs/dialog_conversation/dialog_conversation.tscn"),
  {"conversation": conv},
  true
)
var result = await finished_signal
```

## Spawning a Bullet from Player
```gdscript
var bullet := preload("res://scenes/bullet.tscn").instantiate()
bullet.stat = preload("res://resources/bullets/carrot.tres")
add_child(bullet)
bullet.init_bullet($Player/%BulletSpawn.global_position, get_global_mouse_position(), Bullet.Type.PLAYER)
```

## Using CameraMan
```gdscript
$CameraMan.follow_target($Player)
$CameraMan.zoom_to(0.9, 0.4)
$CameraMan.shake(6, 0.25)
```
