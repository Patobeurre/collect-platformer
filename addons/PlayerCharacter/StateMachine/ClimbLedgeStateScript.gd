extends State

class_name ClimbLedgeState

var stateName : String = "ClimbLedge"

var cR : CharacterBody3D

var dest_pos : Vector3
var is_dest_pos_ready : bool = false

@onready var test_mesh = preload("res://models/sphere.tscn")


func enter(charRef : CharacterBody3D):
	cR = charRef
	
	verifications()
	
	cR.velocity = Vector3.ZERO
	


func verifications():
	is_dest_pos_ready = false
	if cR.ledgeCheckLow.is_colliding():
		var dir = -cR.ledgeCheckLow.get_collision_normal().normalized()
		var origin = cR.ledgeCheckLow.get_collision_point()
		origin += 0.05 * dir
		var end = origin
		end.y += 1
		var query = PhysicsRayQueryParameters3D.create(end, origin)
		query.set_hit_from_inside(true)
		var result = get_tree().root.get_world_3d().direct_space_state.intersect_ray(query)
		if result.has("position"):
			print(result)
			dest_pos = result.position
			dest_pos.y += 0.05
			is_dest_pos_ready = true


#func get_destination_point()

func move_to_destination():
	print(cR.global_position)
	print(dest_pos)
	cR.global_position = dest_pos
	transitioned.emit(self, "IdleState")


func physics_update(delta : float):
	cR.velocity = Vector3.ZERO
	if is_dest_pos_ready:
		move_to_destination()


func _instantiate_test_mesh(position : Vector3):
	var obj = test_mesh.instantiate()
	add_child(obj)
	obj.global_position = position
