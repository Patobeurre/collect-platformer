extends Node3D
class_name BreakableObject

@export var res: BreakableObjRes = null
@export var anim_squash: String = "squash_stretch"
@export var anim_appear: String = "appear"

@onready var mesh_node :Node3D = $Mesh
@onready var anim_player :AnimationPlayer = $AnimationPlayer

@onready var timer :Timer = $RespawnCD

var collider :Node3D = null


func _ready() -> void:
	if res != null:
		loadRes(res)


func init(init_res :BreakableObjRes) -> void:
	loadRes(init_res)


func clearMesh() -> void:
	for child in mesh_node.get_children():
		child.queue_free()
	
	if collider != null:
		collider.queue_free()


func loadRes(res_to_load :BreakableObjRes) -> void:
	res = res_to_load.duplicate()
	anim_player.stop()
	
	instantiate_mesh()


func instantiate_mesh() -> void:
	clearMesh()
	
	res.currentLife = res.lifeMax
	
	var obj = res.scene.instantiate()
	mesh_node.add_child(obj)
	mesh_node.visible = false
	
	collider = Utils.find(mesh_node, PhysicsBody3D)
	collider.reparent(self)
	
	if res.animateOnInstantiate:
		anim_player.play(anim_appear)
	else:
		mesh_node.visible = true


func take_hit(amount :int) -> void:
	anim_player.stop()
	anim_player.play(anim_squash)
	res.currentLife -= amount
	if res.currentLife <= 0:
		selfDestroy()


func selfDestroy() -> void:
	Inventory.add_collectable_list(res.collectable_list)
	if res.isRespawnable:
		clearMesh()
		timer.start(res.timeToRespawn)
	else:
		queue_free()


func _on_respawn_cd_timeout() -> void:
	instantiate_mesh()
