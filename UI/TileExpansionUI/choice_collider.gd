extends StaticBody3D


@export var parent :Node3D = null
@export var res :CreationTileRes = null

func interact() -> void:
	if parent != null:
		parent.select_choice(res)
