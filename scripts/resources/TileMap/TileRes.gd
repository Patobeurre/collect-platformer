extends Resource
class_name TileRes

@export var coords :Vector2 = Vector2.ZERO
@export var h :int = 0

@export var collectable_amount :int = 2
@export var biome :BiomeRes = BiomeRes.new()

@export var collectables :Array[BreakableObjRes] = []
@export var structure :PackedScene = null

@export var scene :PackedScene = preload("res://scenes/test_gridmap/tile.tscn")
static var TILE_SIZE = 10
static var HEIGHT_OFFSET = 2

var isAvailable :bool = true
var isBlocked :bool = false
var animateOnInstantiate :bool = true

var node3D :TileObject = null


func get_scene() -> PackedScene:
	return scene


static func create(new_x: int, new_y :int, new_h :int) -> TileRes:
	var instance = TileRes.new()
	instance.coords = Vector2(new_x, new_y)
	instance.h = new_h
	instance.biome = Grid.get_biome_by_height(instance.h)
	return instance


func get_3d_coords() -> Vector3:
	return Vector3(coords.x, h, coords.y)

func get_world_position() -> Vector3:
	return Vector3(coords.x * TILE_SIZE, h * HEIGHT_OFFSET, coords.y * TILE_SIZE)
