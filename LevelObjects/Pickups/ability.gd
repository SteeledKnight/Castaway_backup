@tool
@icon("uid://vil1c7t6gemb")
class_name AbilityPickup extends Node3D

#enum Type {HIGH_JUMP, N_A}
@export_custom(PROPERTY_HINT_ENUM, "high_jump,N_A") var ability : StringName :
	set(value):
		ability = value
		_set_mesh(value)
const color_match : Dictionary = {
	&"high_jump" : Color.FIREBRICK,
	&"N_A" : Color.WHITE
		}


@onready var mesh: MeshInstance3D = %Mesh
@onready var area_3d: Area3D = %Area3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	var player : Player = get_tree().get_first_node_in_group("Player")
	if player.has_ability(ability):
		queue_free()
		return
	animation_player.play("pulse")
	area_3d.body_entered.connect(_on_body_entered)

func _set_mesh(_v):
	if Engine.is_editor_hint():
		if mesh:
			var mat = mesh.get_active_material(0)
			mat.albedo_color = Color(color_match[_v], 0.25)
			mat.emission = Color(color_match[_v])

func _on_body_entered(p : Player) -> void:
	p.abilities[ability] = true
	p.set_abilities()
	
	var mat := mesh.get_active_material(0) as StandardMaterial3D
	
	var tween := create_tween()
	tween.set_parallel(true)  # run both tweens simultaneously
	
	tween.tween_property(mat, "albedo_color:a", 0.0, .5)
	tween.tween_property(mat, "emission_energy_multiplier", 0.0, .5)
	await tween.finished
	queue_free()
