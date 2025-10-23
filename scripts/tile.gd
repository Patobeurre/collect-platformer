extends Node3D
class_name TileObject

@export var res :TileRes = null

@onready var mesh_node :Node3D = $MainNode/Mesh
@onready var mesh :MeshInstance3D = null

@onready var collectables_node :Node3D = $MainNode/Collectables
@onready var breakable_obj_scene :PackedScene = preload("res://models/breakables/BreakableObject.tscn")
var collectable_pos_nodes :Array[Node] = []

@onready var expand_left :ExpandNode = $"MainNode/Borders/ExpandLeft"
@onready var expand_right :ExpandNode = $"MainNode/Borders/ExpandRight"
@onready var expand_front :ExpandNode = $"MainNode/Borders/ExpandFront"
@onready var expand_back :ExpandNode = $"MainNode/Borders/ExpandBack"

@onready var anim_player :AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	mesh = mesh_node.find_child("BaseTileMesh")
	collectable_pos_nodes = collectables_node.get_children()
	collectable_pos_nodes.shuffle()


func init(tileRes :TileRes) -> void:
	res = tileRes
	res.node3D = self
	
	apply_biome_material()
	
	instantiate_collectables()
	
	if res.animateOnInstantiate:
		animate_on_instantiate()
	
	expand_back.init(res, Vector2(-1,0))
	expand_front.init(res, Vector2(1,0))
	expand_right.init(res, Vector2(0,1))
	expand_left.init(res, Vector2(0,-1))


func apply_biome_material() -> void:
	mesh.material_override = res.biome.material


func instantiate_collectables() -> void:
	var possible_collectables = res.biome.collectablesTypes
	
	if possible_collectables.is_empty():
		return
	
	for i in range(res.collectable_amount):
		var collectable :BreakableObjRes = possible_collectables.pick_random()
		instantiate_collectable(collectable)

func instantiate_collectable(collectable :BreakableObjRes) -> void:
	var pos_node = collectable_pos_nodes.pop_front()
	if pos_node == null:
		return
		
	res.collectables.append(collectable)
	var breakable_obj :BreakableObject = breakable_obj_scene.instantiate()
	pos_node.add_child(breakable_obj)
	breakable_obj.position = Vector3.ZERO
	breakable_obj.rotation.y = deg_to_rad(randf() * 360)
	breakable_obj.rotation.z = deg_to_rad(randf_range(-6, 6))
	breakable_obj.init(collectable)


func get_new_collectable_pos() -> void:
	return collectable_pos_nodes.pop_front()


func animate_on_instantiate() -> void:
	anim_player.play("lift_up")
