# UiConfirmDialog (game_kit/ui/components/ui_confirm_dialog/ui_confirm_dialog.gd)

- **class**: extends `BaseDialog`
- **onready**: `label: Label`, `button: Button`
- **functions**:
  - `set_data(data)` expects `{ text: String, button_text: String }`
  - `_on_button_pressed()` emits `finished("ok")`

Example:
```gdscript
var dlg = preload("res://game_kit/ui/components/ui_confirm_dialog/ui_confirm_dialog.tscn").instantiate()
$DialogManager.dialog_root.add_child(dlg)
dlg.set_data({"text":"Are you sure?","button_text":"OK"})
# Or use DialogManager.open_dialog for managed lifecycle
```