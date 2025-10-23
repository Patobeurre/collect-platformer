extends Resource
class_name Pattern


@export var new_tile_coords :Array[Vector2] = []
@export var blocked_tile_coords :Array[Vector2] = []

static var UP :Vector2 = Vector2(1,0)


static func to_world(pattern :Pattern, from :Vector2, direction :Vector2) -> Pattern:
	var new_pattern :Pattern = Pattern.new()
	var angle = UP.angle_to(direction)
	
	for coord in pattern.new_tile_coords:
		var rotated_coord = coord.rotated(angle)
		new_pattern.new_tile_coords.append(from + rotated_coord)
	
	for coord in pattern.blocked_tile_coords:
		var rotated_coord = coord.rotated(angle)
		new_pattern.blocked_tile_coords.append(from + rotated_coord)
	
	return new_pattern
