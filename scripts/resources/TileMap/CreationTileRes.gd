extends Resource
class_name CreationTileRes


@export var from :Vector2 = Vector2.ZERO
@export var to :Vector2 = Vector2.ZERO
@export var h :int = 0
var biome :BiomeRes = null
var pattern :Pattern = null


static func create(from, to, biome, pattern, h) -> CreationTileRes:
	var res = CreationTileRes.new()
	res.from = from
	res.to = to
	res.h = h
	res.biome = biome
	res.pattern = Pattern.to_world(pattern, from, to)
	return res
