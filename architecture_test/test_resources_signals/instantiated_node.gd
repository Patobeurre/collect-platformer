extends Node3D
class_name InstantiatedNode


@export var binded_res :ResWithSignal = null


func _ready() -> void:
	init(ResWithSignal.new())


func init(res :ResWithSignal) -> void:
	bind_res(res)


func bind_res(res :ResWithSignal) -> void:
	binded_res = res
	binded_res.bind_node(self)
	res.on_integer_update.connect(change_value)


func change_value(new_i :int) -> void:
	print(new_i)
