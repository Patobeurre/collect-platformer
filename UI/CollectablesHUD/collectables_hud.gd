extends Control
class_name CollectableHUD


@onready var woodAmountText :RichTextLabel = $VBoxContainer/WoodContainer/AmountTextLabel
@onready var stoneAmountText :RichTextLabel = $VBoxContainer/StoneContainer/AmountTextLabel


func _ready() -> void:
	Inventory.on_collectable_added.connect(amountChanged)


func amountChanged(collectable :CollectableWithQteRes) -> void:
	var text_node = null
	if collectable.res.name == "Wood":
		text_node = woodAmountText
	elif collectable.res.name == "Stone":
		text_node = stoneAmountText
	
	text_node.text = str(Inventory.collectables[collectable.res])
