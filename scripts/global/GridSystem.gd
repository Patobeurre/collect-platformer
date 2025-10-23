extends Node

var GRID_SIZE :int = 50

var grid :Array = []

var currentTile :TileRes = null
var startingTile :TileRes = null

var all_biomes :Array[BiomeRes] = []
var defaultBiome :BiomeRes = preload("res://scripts/resources/TileMap/biomes/Grass.tres")


signal on_grid_loaded
signal on_tile_created (Vector2)


func _ready() -> void:
	initialize_grid()
	load_biomes()
	
	grid[25][25].isAvailable = false
	startingTile = grid[25][25]
	currentTile = startingTile
	
	init_tower()
	
	grid[5][5].isAvailable = false
	grid[5][6].isAvailable = false
	grid[5][6].h = -3
	grid[6][6].isAvailable = false
	grid[6][6].h = -4
	grid[5][7].isAvailable = false
	grid[5][7].h = -5


func init_tower() -> void:
	grid[30][30].isAvailable = false
	grid[30][30].h = 10
	grid[30][30].structure = load("res://models/structures/tower_lowpoly.tscn")
	grid[30][29].isAvailable = false
	grid[30][29].h = 10
	grid[29][30].isAvailable = false
	grid[29][30].h = 8
	grid[29][29].isAvailable = false
	grid[29][29].h = 7
	grid[30][28].isAvailable = false
	grid[30][28].h = 9
	

func initialize_grid() -> void:
	grid = []
	
	for x in GRID_SIZE:
		var row = []
		for y in GRID_SIZE:
			row.append(TileRes.create(x, y, randi_range(-1, 1)))
		grid.append(row)
	
	on_grid_loaded.emit()


func load_biomes() -> void:
	var file_paths = Utils.get_all_file_paths("res://scripts/resources/TileMap/biomes/")
	for path in file_paths:
		all_biomes.append(load(path))


func get_biome_by_height(h :int) -> BiomeRes:
	for biome in all_biomes:
		if biome.is_height_in_range(h):
			return biome
	return defaultBiome


func create_tile(coords :Vector2, from :TileRes) -> void:
	var new_tile = get_tile(coords)
	
	if new_tile == null: return
	if not new_tile.isAvailable: return
	
	new_tile.h = from.h + 1
	new_tile.biome = from.biome
	new_tile.isAvailable = false
	
	on_tile_created.emit(coords)


func create_tile_from_res(res :CreationTileRes) -> void:
	var local_pattern = res.pattern
	print(local_pattern.new_tile_coords)
	
	if local_pattern == null:
		local_pattern = generate_pattern(res.from, res.to)
	
	for coords in local_pattern.new_tile_coords:
		var new_tile = get_tile(coords)
		
		if new_tile == null: continue
		if not new_tile.isAvailable: continue
		
		new_tile.h = res.h
		new_tile.biome = get_biome_by_height(res.h)
		new_tile.isAvailable = false
		
		on_tile_created.emit(new_tile.coords)
	
	for coords in local_pattern.blocked_tile_coords:
		var blocked_tile = get_tile(coords)
		
		if blocked_tile == null: continue
		
		blocked_tile.isAvailable = false
		blocked_tile.isBlocked = true
		
		on_tile_created.emit(blocked_tile.coords)


func generate_pattern(from :Vector2, direction :Vector2) -> Pattern:
	var pattern :Pattern = load("res://scripts/resources/TileMap/patterns/Simple.tres").duplicate()
	var angle = Vector2(1,0).angle_to(direction)
	
	var coords :Array[Vector2] = []
	for coord in pattern.new_tile_coords:
		var rotated_coord = coord.rotated(angle)
		coords.append(from + rotated_coord)
	pattern.new_tile_coords = coords
	
	var blocked_coords :Array[Vector2] = []
	for coord in pattern.blocked_tile_coords:
		var rotated_coord = coord.rotated(angle)
		blocked_coords.append(from + rotated_coord)
	pattern.blocked_tile_coords = blocked_coords
	
	return pattern


func generate_choice(from :TileRes, direction :Vector2, h_diff :int) -> CreationTileRes:
	var h = from.h + h_diff
	var biome = get_biome_by_height(h)
	var pattern = biome.patterns.pick_random()
	var res :CreationTileRes = CreationTileRes.create(from.coords, direction, biome, pattern, h)
	return res


func get_distance_from_starting_tile(coords :Vector2) -> int:
	return ceil(startingTile.coords.distance_to(coords))


func get_tile(coords :Vector2) -> TileRes:
	if not is_coord_valid(coords):
		return null
	return grid[coords.x][coords.y]


func get_all_tiles() -> Array:
	var all_tiles = []
	for row in grid:
		all_tiles.append_array(row.filter(func(element): return not element.isAvailable and not element.isBlocked))
	return all_tiles


func get_4_neighbours(res :TileRes) -> Array:
	var neighbours = []
	
	if res.coords.x > 0:
		neighbours.append(grid[res.coords.x-1][res.coords.y])
	if res.coords.x < GRID_SIZE - 1:
		neighbours.append(grid[res.coords.x+1][res.coords.y])
	if res.coords.y > 0:
		neighbours.append(grid[res.coords.x][res.coords.y-1])
	if res.coords.y < GRID_SIZE - 1:
		neighbours.append(grid[res.coords.x][res.coords.y+1])
		
	return neighbours


func is_coord_valid(coords :Vector2):
	return \
		coords.x >= 0 and \
		coords.x < GRID_SIZE and \
		coords.y >= 0 and \
		coords.y < GRID_SIZE


func has_available_neighbour(res :TileRes, direction :Vector2) -> bool:
	var neighbour_coord = res.coords + direction
	if is_coord_valid(neighbour_coord):
		if grid[neighbour_coord.x][neighbour_coord.y].isAvailable:
			return true
	return false
