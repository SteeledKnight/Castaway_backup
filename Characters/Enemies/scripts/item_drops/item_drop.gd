@icon("uid://cbmbo2kqkiiay")
class_name ItemDrop extends Node3D

@export var items : Array[ItemData]

func _ready() -> void:
	if owner is Enemy:
		owner.was_killed.connect(drop_item)
	elif owner is BreakableProp:
		owner.destroyed.connect(drop_item)
	else:
		push_warning("Item Drop should be assigned to a Enemy or BreakableProp")


func drop_item(_a: Attackbox) -> void:
	var origin := Tools.get_area_center(owner.hitbox)  # capture self's position now, while self is still valid
	for i in items:
		if i.drop_chance < randf():
			continue
		var item_scene = load(i.item)
		var count: int = randi_range(i.minimum_quantity, i.maximum_quantity)
		for j in count:
			print("item dropped")
			var item = item_scene.instantiate()
			var pos := origin
			pos.x += randf() * 0.25
			_spawn_item.call_deferred(item, pos)

func _spawn_item(item: Node3D, pos: Vector3) -> void:
	owner.add_sibling(item)
	item.global_position = pos
