extends Node3D

@export var ray_length :float = 2.0


func _physics_process(delta):
	if Input.is_action_just_pressed("attack"):
		var mouse_pos = get_viewport().get_mouse_position()
		var camera = get_viewport().get_camera_3d()
		var from = camera.project_ray_origin(mouse_pos)
		var to = from + camera.project_ray_normal(mouse_pos) * ray_length
		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(from, to, 4)
		query.collide_with_areas = true
		var result = space_state.intersect_ray(query)
		if not result.is_empty():
			var collision_object = result.collider
			var parent_node = collision_object.get_parent()
			print(parent_node.name)
			if parent_node.has_method("take_hit"):
				parent_node.take_hit(1)
