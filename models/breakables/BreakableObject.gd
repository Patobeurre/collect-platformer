extends Node3D
class_name BreakableObject

@export var res: BreakableObjRes = null
@export var anim_name: String = "squash_stretch"

@onready var mesh_node :Node3D = $Mesh
@onready var anim_player :AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	if res != null:
		loadRes(res)


func init(init_res :BreakableObjRes) -> void:
	loadRes(init_res)


func clearMesh() -> void:
	for child in mesh_node.get_children():
		child.queue_free()


func loadRes(res_to_load :BreakableObjRes) -> void:
	res = res_to_load.duplicate()
	anim_player.stop()
	
	clearMesh()
	
	var obj = res.scene.instantiate()
	mesh_node.add_child(obj)
	
	var collider = Utils.find(mesh_node, PhysicsBody3D)
	collider.reparent(self)


func take_hit(amount :int) -> void:
	anim_player.stop()
	anim_player.play(anim_name)
	res.life -= amount
	if res.life <= 0:
		selfDestroy()


func selfDestroy() -> void:
	Inventory.add_collectable_list(res.collectable_list)
	queue_free()
