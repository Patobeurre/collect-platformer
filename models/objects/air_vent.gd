extends Node3D


@export var speed : float = 5.0
@export var node_to_rotate : Node3D


func _physics_process(delta: float) -> void:
	node_to_rotate.rotation.x += speed * delta
