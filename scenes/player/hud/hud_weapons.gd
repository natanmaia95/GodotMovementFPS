extends MarginContainer

@export var inventory_component : InventoryComponent

func _ready():
	if inventory_component:
		inventory_component.selected_item_changed.connect(on_selected_item_changed)

func on_selected_item_changed():
	if inventory_component.selected_index == -1:
		%DebugLabel1.text = "Selected Item:\n[NONE]"
	else:
		var index = inventory_component.selected_index
		var item_name = inventory_component.get_selected_item().item_name
		%DebugLabel1.text = "Selected Item:\n%d:[%s]" % [index,item_name]
