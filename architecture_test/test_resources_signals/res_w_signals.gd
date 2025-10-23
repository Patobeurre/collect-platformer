extends Resource
class_name ResWithSignal


@export var text :String = "Text"
@export var integer :int = 1

var instantiated_node :InstantiatedNode = null

signal on_integer_update(int)


func set_integer(new_i :int):
	integer = new_i
	on_integer_update.emit(integer)

func bind_node(node :InstantiatedNode) -> void:
	instantiated_node = node
