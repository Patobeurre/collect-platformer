extends Node3D

@export var input_name :String = ""
@export var ray_length :float = 1.0
@export var mask :int = 1
@export var method_to_call :String = "interact"


func _physics_process(delta):
	if Input.is_action_just_pressed(input_name):
		var mouse_pos = get_viewport().get_mouse_position()
		var camera = get_viewport().get_camera_3d()
		var from = camera.project_ray_origin(mouse_pos)
		var to = from + camera.project_ray_normal(mouse_pos) * ray_length
		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(from, to, mask)
		query.collide_with_areas = true
		var result = space_state.intersect_ray(query)
		if not result.is_empty():
			var parent_node = result.collider
			if parent_node.has_method(method_to_call):
				var callable = Callable(parent_node, method_to_call)
				callable.call()
