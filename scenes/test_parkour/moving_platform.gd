extends Node3D

@export var speed : float = 5.0
@export var start_pos : Vector3
@export var start_at_current_pos : bool
@export var end_pos : Vector3
@export var back_and_forth : bool

var moveDir : Vector3


func _ready() -> void:
	if start_at_current_pos:
		start_pos = global_position
	
	global_position = start_pos
	
	moveDir = (end_pos - start_pos).normalized()

func _physics_process(delta: float) -> void:
	checkDirection()
	
	global_position += moveDir * speed * delta

func checkDirection():
	var new_dir = (end_pos - global_position).normalized()
	
	if new_dir == moveDir:
		return
	
	global_position = end_pos
	
	if back_and_forth:
		moveDir = new_dir
		end_pos = start_pos
		start_pos = global_position
