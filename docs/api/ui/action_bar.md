# UI Action Bar

## UiActionBarItemResource
- **class**: `UiActionBarItemResource` extends `Resource`
- **exports**:
  - `id: String`
  - `icon: Texture2D`

## UiActionBarItem
- **class**: `UiActionBarItem` extends `Control`
- **exports**:
  - `item: UiActionBarItemResource`
  - `selected: bool`
- **signals**:
  - `clicked(item: UiActionBarItemResource)`

## UiActionBar
- **class**: `UiActionBar` extends `Control`
- **exports**:
  - `items: Array[UiActionBarItemResource]`
  - `selected_item: String`
- **signals**:
  - `item_clicked(item: UiActionBarItemResource)`
- **functions**:
  - `get_items_nodes() -> Array[UiActionBarItem]`

Example:
```gdscript
var item1 := UiActionBarItemResource.new()
item1.id = "carrot"
item1.icon = preload("res://assets/export/icons/prop_carrot_@0.5x.png")

var item2 := UiActionBarItemResource.new()
item2.id = "seed"
item2.icon = preload("res://assets/export/icons/prop_pumpkin-seed_@0.5x.png")

$UiActionBar.items = [item1, item2]
$UiActionBar.item_clicked.connect(func(item):
  print("Selected:", item.id)
)
```