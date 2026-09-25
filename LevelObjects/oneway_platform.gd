class_name OnewayPlatform extends Node3D

const PLATFORM_LAYER := 2

@onready var static_body_3d: StaticBody3D = %StaticBody3D
@onready var trigger_area: Area3D = %TriggerArea

func _ready():
	static_body_3d.set_collision_layer_value(PLATFORM_LAYER, true)
	static_body_3d.set_collision_layer_value(1, false)
	trigger_area.add_to_group("one_way_trigger")
