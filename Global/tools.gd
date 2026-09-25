extends Node

func get_area_center(area: Area3D) -> Vector3:
	var total_position := Vector3.ZERO
	var shape_count := 0
	
	for child in area.get_children():
		if child is CollisionShape3D:
			total_position += child.global_position
			shape_count += 1
			
	if shape_count > 0:
		return total_position / shape_count
		
	# Fallback to the area's origin if no shapes are found
	return area.global_position
