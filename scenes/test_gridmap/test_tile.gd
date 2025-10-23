extends Node3D


@onready var camera :Camera3D = $Camera3D

var res :TileRes = TileRes.new()


func _ready() -> void:
	camera.look_at(Vector3(10,0,10))


func instantiateTile() -> void:
	var tile = res.scene.instantiate()
	add_child(tile)
	tile.global_position = res.get_world_position()
	tile.init(res)

func deleteTile() -> void:
	if res.node3D != null:
		res.node3D.queue_free()


func _on_create_tile_anim_btn_pressed() -> void:
	deleteTile()
	instantiateTile()


func _on_remove_tile_pressed() -> void:
	deleteTile()


func _on_anim_check_box_toggled(toggled_on: bool) -> void:
	res.animateOnInstantiate = toggled_on


func _on_x_value_changed(value: float) -> void:
	res.coords.x = int(value)

func _on_y_value_changed(value: float) -> void:
	res.coords.y = int(value)


func _on_add_tree_btn_pressed() -> void:
	if res.node3D != null:
		res.node3D.add_collectable(load("res://scripts/resources/BreakableResources/Pine.tres"))
