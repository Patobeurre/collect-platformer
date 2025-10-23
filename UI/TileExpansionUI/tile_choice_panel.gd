extends Panel


@export var res :CreationTileRes = null

@onready var heightLabel :RichTextLabel = $MarginContainer/VBoxContainer/HSplitContainer/HeightLabel


func init(new_res :CreationTileRes) -> void:
	res = new_res
	heightLabel.text = str(res.h)
