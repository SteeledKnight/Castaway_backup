extends Camera3D

var player: Player

@export_category("Follow Settings")
@export var base_offset: Vector3 = Vector3(0, 2, 8)
@export var follow_speed: float = 10.0

@export_category("Metroidvania Features")
@export var look_ahead_distance: float = 3.0
@export var look_ahead_speed: float = 2.0

@export_category("Camera Limits")
@export var use_limits: bool = true
@export var level_bounds : Node3D
var min_bounds: Vector3 = Vector3(-50, -10, 0)
var max_bounds: Vector3 = Vector3(50, 20, 0)

@export_category("Visual Effects")
var camera_shake_strength : float = 0.0
@export var max_camera_shake : float = 2.0
@export var shake_decay_rate : float = 6.0

var current_look_ahead: Vector3 = Vector3.ZERO
var last_player_position: Vector3 = Vector3.ZERO


func _ready() -> void:
	#VFX
	VfxManager.camera_shook.connect( _apply_camera_shake )
	#TODO: max_camera_shake = CREATE A SETTING
	
	rotation = Vector3.ZERO
	
	#find and look at player
	while not player:
		await get_tree().process_frame
		player = get_tree().get_first_node_in_group("Player")
	if player:
		last_player_position = player.global_position
		global_position = player.global_position + base_offset
	
	_set_bounds_from_area(level_bounds)

func _process(delta: float) -> void:
	var offset = Vector3(
		randf_range(-camera_shake_strength, camera_shake_strength),
		randf_range(-camera_shake_strength, camera_shake_strength),
		0.0
	)
	
	#TODO: implement up/down look ahead based off input
	if not player:
		return

	var player_velocity = player.global_position - last_player_position
	last_player_position = player.global_position

	var target_look_ahead = Vector3.ZERO
	
	if abs(player_velocity.x) > 0.001:
		target_look_ahead = player_velocity.normalized() * look_ahead_distance
		target_look_ahead.y = 0 
		current_look_ahead = current_look_ahead.lerp(target_look_ahead, 1.0 - exp(-follow_speed * delta))
	
	var t = 1.0 - exp(-follow_speed * delta)
	#current_look_ahead = current_look_ahead.lerp(target_look_ahead, t)

	var target_position = player.global_position + base_offset + current_look_ahead

	var new_position = global_position.lerp(target_position.clamp(min_bounds, max_bounds), t)

	new_position.x = clamp(new_position.x, min_bounds.x, max_bounds.x)
	new_position.y = clamp(new_position.y, min_bounds.y, max_bounds.y)
	new_position.z = base_offset.z
	
	global_position = new_position + offset
	camera_shake_strength = lerp(camera_shake_strength, 0.0, shake_decay_rate * delta)

func _set_bounds_from_area(area: Area3D) -> void:
	var shape_node := area.get_node("CollisionShape3D") as CollisionShape3D
	if not shape_node or not shape_node.shape is BoxShape3D:
		push_warning("bounds_area needs a CollisionShape3D with a BoxShape3D")
		return

	var box := shape_node.shape as BoxShape3D
	var half_extents := box.size * 0.5

	# half_extents is in the shape's local space — transform to world space
	# accounting for the CollisionShape3D's own transform and the Area3D's transform
	var local_min := -half_extents
	var local_max := half_extents

	# Get all 8 corners in local space, transform each to global, then take min/max
	# (handles rotation/scale correctly, not just translation)
	var corners := []
	for x in [local_min.x, local_max.x]:
		for y in [local_min.y, local_max.y]:
			for z in [local_min.z, local_max.z]:
				corners.append(Vector3(x, y, z))

	var global_corners: Array[Vector3] = []
	for c in corners:
		global_corners.append(shape_node.global_transform * c)

	var result_min := global_corners[0]
	var result_max := global_corners[0]
	for c in global_corners:
		result_min = result_min.min(c)
		result_max = result_max.max(c)

	min_bounds = result_min
	max_bounds = result_max

func _apply_camera_shake(strength : float) -> void:
	camera_shake_strength = min(strength, max_camera_shake)
