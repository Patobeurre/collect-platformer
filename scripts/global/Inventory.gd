extends Node


@export var collectables :Dictionary = {}

signal on_collectable_added(CollectableWithQteRes)


func _ready() -> void:
	var file_paths = Utils.get_all_file_paths("res://scripts/resources/Collectables/")
	for path in file_paths:
		add_collectable(load(path), 20)


func add_collectable(res :CollectableRes, qte :int) -> void:
	if qte <= 0:
		return
	
	if collectables.has(res):
		collectables[res] += qte
	else:
		collectables[res] = qte
	
	on_collectable_added.emit(CollectableWithQteRes.create(res, qte))


func add_collectable_list(collectable_list :Array[CollectableWithQteRes]) -> void:
	for collectable in collectable_list:
		add_collectable(collectable.res, collectable.quantity)


func check_cost(cost :CollectableWithQteRes) -> bool:
	return collectables[cost.res] >= cost.quantity

func check_costs(costs :Array[CollectableWithQteRes]) -> bool:
	for cost in costs:
		if not check_cost(cost):
			return false
	return true


func remove_collectable(collectable :CollectableWithQteRes) -> bool:
	if not check_cost(collectable):
		return false
	collectables[collectable.res] -= collectable.quantity
	
	on_collectable_added.emit(CollectableWithQteRes.create(collectable.res, collectables[collectable.res]))
	return true

func remove_collectables(costs :Array[CollectableWithQteRes]) -> bool:
	if not check_costs(costs):
		return false
	for cost in costs:
		remove_collectable(cost)
	
	return true
