extends Node3D
class_name ExpandNode

@export var fromTile :TileRes = null
@export var direction :Vector2 = Vector2.ZERO

#@export var baseCost = preload("res://scripts/resources/Costs/BaseCost.tres")
#var cost :CostCollectable = null
@export var baseCost :CostCollectable = preload("res://scripts/resources/Costs/BaseCost.tres")

@onready var plus_icon :Node3D = $Sprite3D
@onready var GUI_node :Node3D = $GUI
@onready var choices_ui = $GUI/Sprite3D/SubViewport/Control


func _ready() -> void:
	Grid.on_tile_created.connect(new_tile_created)


func init(from :TileRes, dir :Vector2) -> void:
	fromTile = from
	direction = dir
	update()


func interact() -> void:
	plus_icon.visible = false
	GUI_node.visible = true
	
	choices_ui.populate(Grid.generate_choice(fromTile, direction, -1))
	choices_ui.populate(Grid.generate_choice(fromTile, direction, 0))
	choices_ui.populate(Grid.generate_choice(fromTile, direction, 1))
	choices_ui.set_cost(get_cost())


func select_choice(new_res :CreationTileRes) -> void:
	if Inventory.remove_collectables(get_cost()):
		var res = Grid.generate_choice(fromTile, direction, new_res.h)
		Grid.create_tile_from_res(res)


func new_tile_created(coords :Vector2) -> void:
	if not Grid.has_available_neighbour(fromTile, direction):
		queue_free()


func _physics_process(delta: float) -> void:
	GUI_node.look_at(Global.player_global_pos)


func get_cost() -> Array[CollectableWithQteRes]:
	var distance = Grid.get_distance_from_starting_tile(fromTile.coords + direction)
	var costs :Array[CollectableWithQteRes] = []
	for cost in baseCost.costs:
		var c = cost.duplicate()
		c.quantity *= distance
		costs.append(c)
	return costs


func update() -> void:
	visible = Grid.has_available_neighbour(fromTile, direction)
