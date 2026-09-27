@tool
@icon("uid://chm0dp3xvhek3")
class_name Enemy extends CharacterBody3D

#region signals
signal direction_changed(new_dir)
signal was_hit(a : Attackbox)
@warning_ignore("unused_signal")
signal was_killed()
#endregion

#region exports
@export var health : float = 3
@export var move_speed : float = .5
@export_enum("Left", "Right") var starting_direction = "Right"
@export var affected_by_gravity : bool = true

@export_category("Audio")
@export var death_sound : AudioStream
#endregion

#region references
@onready var mesh: Node3D = %Mesh
var animation : AnimationPlayer
var hitbox : Hitbox
var hazard_area : HazardArea

var state_machine : EnemyStateMachine
var decision_engine : DecisionEngine
var blackboard : Blackboard
#endregion

var dir : float = 1.0
var move_tween : Tween

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready() -> void:
	if Engine.is_editor_hint():
		set_physics_process(false)
		return
	setup()

func setup() -> void:
	blackboard = Blackboard.new()
	blackboard.health = health
	
	_make_meshes_unique(mesh)
	
	for c in get_children():
		if c is AnimationPlayer and not animation:
			animation = c
		#elif c is MeshInstance3D and not mesh:
			#mesh = c
		elif c is Hitbox and not hitbox:
			hitbox = c
			c.damaged.connect(_on_damaged)
		elif c is HazardArea and not hazard_area:
			hazard_area = c
		elif c is EnemyStateMachine and not state_machine:
			state_machine = c
		elif c is DecisionEngine and not decision_engine:
			decision_engine = c
		
	if state_machine and decision_engine:
		state_machine.setup(self, blackboard)
		decision_engine.enemy = self
		decision_engine.blackboard = blackboard
	else:
		set_physics_process(false)

func _physics_process(delta: float) -> void:
	blackboard.update_distance_to_target(global_position)
	state_machine.change_state(decision_engine.decide())
	if not is_on_floor() and affected_by_gravity:
		velocity.y -= gravity * delta
	state_machine.physics_update(delta)
	move_and_slide()

func change_dir() -> void:
	dir *= -1.0
	blackboard.dir = dir
	direction_changed.emit()
	
	if move_tween:
		move_tween.kill()
	move_tween = create_tween()
	move_tween.set_parallel(true)
	
	var target_rotation_y := 0.0 if dir > 0 else -PI  # 180 degrees in radians
	move_tween.tween_property(self, "rotation:y", target_rotation_y, 0.5)
	move_tween.tween_property(self, "velocity:x", dir * move_speed, 0.5)

func play_animation(anim : String) -> void:
	if animation.has_animation(anim):
		animation.play(anim)
	else:
		printerr("Animation missing: ", anim)

func _make_meshes_unique(node: Node) -> void:
	if node is MeshInstance3D:
		_duplicate_mesh_resource(node)
		_duplicate_mesh_instance_materials(node)
	for child in node.get_children():
		_make_meshes_unique(child)

func _duplicate_mesh_resource(mi: MeshInstance3D) -> void:
	if mi.mesh:
		mi.mesh = mi.mesh.duplicate(true)  # true = deep copy, duplicates subresources too

func _duplicate_mesh_instance_materials(mi: MeshInstance3D) -> void:
	if mi.material_override:
		mi.material_override = mi.material_override.duplicate()
		return

	for i in mi.get_surface_override_material_count():
		var mat = mi.get_surface_override_material(i)
		if mat:
			mi.set_surface_override_material(i, mat.duplicate())
		elif mi.mesh and mi.mesh.surface_get_material(i):
			mi.set_surface_override_material(i, mi.mesh.surface_get_material(i).duplicate())

func _on_damaged(a : Attackbox) -> void:
	was_hit.emit(a)
	blackboard.damage_source = a
	blackboard.health -= a.damage

func _get_configuration_warnings() -> PackedStringArray:
	var warnings : PackedStringArray = []
	
	if not find_children("*", "AnimationPlayer", false):
		warnings.append("Requires an AnimationPlater")
	if not find_children("*", "MeshInstance3D", true, false):
		warnings.append("Requires an Mesh")
	if not find_children("*", "Hitbox", false):
		warnings.append("Requires an Hitbox")
	if not find_children("*", "HazardArea", false):
		warnings.append("Requires an HazardArea")
	if not find_children("*", "EnemyStateMachine", false):
		warnings.append("Requires an EnemyStateMachine")
	if not find_children("*", "DecisionEngine", false):
		warnings.append("Requires an DecisionEngine")
	
	return warnings
