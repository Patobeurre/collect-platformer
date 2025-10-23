extends Resource
class_name BiomeRes


@export var name :String = ""
@export var lower_range :int = 0
@export var upper_range :int = 0
@export var material :Material = StandardMaterial3D.new()

@export var collectablesTypes :Array[BreakableObjRes] = []
@export var patterns :Array[Pattern] = []


func is_height_in_range(h :int) -> bool:
	return h > lower_range and h < upper_range
