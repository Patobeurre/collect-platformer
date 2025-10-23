extends Resource
class_name BreakableObjRes

@export var lifeMax: int = 3
@export var isRespawnable :bool = true
@export var timeToRespawn :float = 5.0

@export var scene: PackedScene = null

@export var collectable_list :Array[CollectableWithQteRes] = []

@export var animateOnInstantiate :bool = true

var currentLife :int = lifeMax
