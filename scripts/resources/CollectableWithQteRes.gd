extends Resource
class_name CollectableWithQteRes


@export var res :CollectableRes = null
@export var quantity :int = 0


static func create(new_res :CollectableRes, new_quantity :int) -> CollectableWithQteRes:
	var collectable_w_qte = CollectableWithQteRes.new()
	collectable_w_qte.res = new_res
	collectable_w_qte.quantity = new_quantity
	return collectable_w_qte
