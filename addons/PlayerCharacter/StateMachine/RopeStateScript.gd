extends State

class_name RopeState

var stateName : String = "Rope"

var cR : CharacterBody3D

var end_rope_position : Vector3
var distance_to_end_point : float

@onready var test_mesh = preload("res://models/sphere.tscn")

func enter(charReference : CharacterBody3D):
	cR = charReference
	end_rope_position = Vector3.ZERO
	
	verifications()
	
	cR.currStamina -= cR.ropeStaminaConsumption

func verifications():	
	if cR.ropeCheck.is_colliding():
		end_rope_position = cR.ropeCheck.get_collision_point()
		_instantiate_test_mesh(end_rope_position)
	
	cR.moveSpeed = cR.ropeSpeed
	cR.moveAccel = cR.ropeAccel
	cR.moveDeccel = cR.ropeDeccel

func exit():
	clearRope()

func update(_delta : float):
	drawRope()
	
	inputManagement()

func inputManagement():
	if Input.is_action_just_pressed(cR.jumpAction):
		transitioned.emit(self, "IdleState")

func checkDistance():
	distance_to_end_point = cR.rope_node.global_position.distance_to(end_rope_position)
	if (distance_to_end_point < cR.ropeMinDistance):
		transitioned.emit(self, "ClimbIdleState")

func physics_update(_delta : float):
	checkDistance()
	
	move(_delta)

func move(delta : float):
	var end_position = end_rope_position
	end_position.y -= 1.55
	cR.moveDirection = (end_position - cR.global_position).normalized()
	
	cR.velocity = lerp(cR.velocity, cR.moveDirection * cR.moveSpeed, cR.moveAccel * delta)

func drawRope():
	clearRope()
	var local_end_pos = cR.to_local(end_rope_position)
	cR.rope_path.curve.add_point(cR.rope_node.position)
	cR.rope_path.curve.add_point(cR.to_local(end_rope_position))

func clearRope():
	cR.rope_path.curve.clear_points()

func _instantiate_test_mesh(position : Vector3):
	var obj = test_mesh.instantiate()
	add_child(obj)
	obj.global_position = position
