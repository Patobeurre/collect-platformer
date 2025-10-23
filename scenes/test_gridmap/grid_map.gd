extends Node3D

@export var tile_scene :PackedScene = null


func _ready() -> void:
	#Grid.on_grid_loaded.connect(init)
	Grid.on_tile_created.connect(add_tile)
	init()


func clearTiles() -> void:
	for child in get_children():
		remove_child(child)


func init() -> void:
	clearTiles()
	print("initialize grid")
	for tileRes :TileRes in Grid.get_all_tiles():
		instantiateTile(tileRes)


func add_tile(coords :Vector2) -> void:
	var tile = Grid.get_tile(coords)
	
	if tile == null: return
	if tile.isBlocked: return
	
	instantiateTile(tile)


func instantiateTile(res :TileRes) -> void:
	var tile_node :Node3D = tile_scene.instantiate()
	add_child(tile_node)
	tile_node.global_position = res.get_world_position()
	tile_node.init(res)
