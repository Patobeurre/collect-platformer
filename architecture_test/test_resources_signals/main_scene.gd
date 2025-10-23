extends Node3D


@export var res :ResWithSignal = ResWithSignal.new()

@onready var node :InstantiatedNode = $InstantiatedNode


func _ready() -> void:
	node.bind_res(res)


func _on_button_pressed() -> void:
	res.set_integer(res.integer + 1)
