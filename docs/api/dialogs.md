# Dialog System

## DialogManager
- **class**: `DialogManager` extends `CanvasLayer`
- **onready**: `dialog_root: Control`, `color_rect: ColorRect`
- **functions**:
  - `open_dialog(scene: PackedScene, data: Dictionary, pause_game := false) -> Signal`
    - Returns the dialog's `finished` signal. If `pause_game` is true, pauses tree while open.

Example:
```gdscript
var finished := $DialogManager.open_dialog(preload("res://game_kit/dialogs/dialog_pause.tscn"), {}, true)
var result = await finished
```

## BaseDialog
- **class**: `BaseDialog` extends `Control`
- **signals**: `finished(_data: Dictionary)`
- **functions**:
  - `set_data(_data: Dictionary)`
  - `close_dialog(data: Dictionary)`

## Conversation Data Model
- **ConversationSpeaker**: `{ id: String, name: String, texture: Texture2D }`
- **ConversationSpeakerArray**: `speakers: Array[ConversationSpeaker]`
- **ConversationLine**: `{ speaker_id: String, text: String }`
- **Conversation** resource:
  - `speakers: ConversationSpeakerArray` (setter indexes dictionary)
  - `json_file: String` (setter loads JSON)
  - `get_line(idx) -> ConversationLine`, `get_line_count() -> int`
  - `get_speaker(id) -> ConversationSpeaker`
  - `validate_lines()` asserts all speakers present

## DialogConversation
- **class**: extends `BaseDialog`
- **set_data(data: Dictionary)** expects `{ conversation: Conversation, line_index?: int, allow_complitly_skip?: bool }`
- **methods**: `update_ui(line)`, `show_next_line()`

Usage:
```gdscript
var conv := Conversation.new()
conv.speakers = preload("res://resources/speakers.tres")
conv.json_file = "res://data/dialog_json/lvl1start.json"
var signal := $DialogManager.open_dialog(preload("res://game_kit/dialogs/dialog_conversation/dialog_conversation.tscn"), {"conversation": conv}, true)
await signal
```