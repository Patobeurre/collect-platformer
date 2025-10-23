extends Control


@onready var tileChoicePanel = preload("res://UI/TileExpansionUI/tile_choice_panel.tscn")
@onready var container = $SplitContainer/HBoxContainer

@onready var woodCostLabel = $SplitContainer/HBoxContainer2/VSplitContainer/CostWoodLabel
@onready var stoneCostLabel = $SplitContainer/HBoxContainer2/VSplitContainer2/CostStoneLabel


func _ready() -> void:
	for child in container.get_children():
		container.remove_child(child)


func populate(res :CreationTileRes) -> void:
	var choice_node = tileChoicePanel.instantiate()
	container.add_child(choice_node)
	choice_node.init(res)


func set_cost(costs :Array[CollectableWithQteRes]) -> void:
	for cost in costs:
		if cost.res.name == "Wood":
			woodCostLabel.text = str(cost.quantity)
		if cost.res.name == "Stone":
			stoneCostLabel.text = str(cost.quantity)
