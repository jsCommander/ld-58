# UI Examples

## Action Bar
```gdscript
var carrot := UiActionBarItemResource.new()
carrot.id = "carrot"
carrot.icon = preload("res://assets/export/icons/prop_carrot_@0.5x.png")

var seed := UiActionBarItemResource.new()
seed.id = "seed"
seed.icon = preload("res://assets/export/icons/prop_pumpkin-seed_@0.5x.png")

$UiActionBar.items = [carrot, seed]
$UiActionBar.item_clicked.connect(func(item):
  print("Selected:", item.id)
)
```

## Progress Bar
```gdscript
$UiProgressBar.max_value = 100
$UiProgressBar.value = 75
```

## Resource Count
```gdscript
$UiResourceCount.count = 5
$UiResourceCount.icon = preload("res://game_kit/assets/icons/icn_heart.png")
```

## Confirm Dialog via DialogManager
```gdscript
var finished = $DialogManager.open_dialog(preload("res://game_kit/ui/components/ui_confirm_dialog/ui_confirm_dialog.tscn"), {
  "text": "Are you sure?",
  "button_text": "OK"
}, true)
var result = await finished
```