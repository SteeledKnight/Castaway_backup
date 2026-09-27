class_name Player extends CharacterBody3D

#region /// signals
signal damage_taken
#endregion

#region /// onreadys
@onready var collision_standing: CollisionShape3D = $CollisionStanding
@onready var collision_crouching: CollisionShape3D = $CollisionCrouching
@onready var hitbox: Hitbox = %Hitbox
@onready var hitbox_standing: CollisionShape3D = $Hitbox/CollisionStanding
@onready var hitbox_crouching: CollisionShape3D = $Hitbox/CollisionCrouching
@onready var attackbox: Attackbox = %Attackbox
#@onready var animation_library_godot_standard: Node3D = $AnimationLibrary_Godot_Standard
@onready var feet: Area3D = %Feet
@onready var anim_player: AnimationPlayer = %model/AnimationPlayer

#endregion

#region /// State Machine Variables
var states : Array[PlayerState]
var current_state : PlayerState :
	get : return states.front()
var previous_state : PlayerState :
	get : return states[1]
#endregion

#region /// constants & exports
@export_category("Physics")
@export var SPEED := 5.0
@export var JUMP_VELOCITY := 4.5
@export var COYOTE_TIME := 0.125
@export var HIGH_JUMP_VELOCITY := 7.5

@export_category("Audio")
@export var jump_audio : AudioStream = preload("uid://duy0u6fbgcupe")
@export var hurt_audio : AudioStream = preload("uid://21xag4uvxegq")
@export var death_audio : AudioStream = preload("uid://1eorbuqbc37n")

const PLATFORM_LAYER := 2
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
#endregion

#region /// player data
var hp = 10 :
	set(value):
		hp = clampf(value, 0, max_hp)
		SignalBus.player_hp_changed.emit(hp, max_hp)
var max_hp = 10 :
	set(value):
		max_hp = value
		SignalBus.player_hp_changed.emit(hp, max_hp)
var inventory : Dictionary
var abilities : Dictionary 
#endregion

#vars
var direction = Vector2.ZERO
var _feet_detectors: Array[Area3D] = []
var wants_drop := false

func _ready() -> void:
	initialize_states()
	set_abilities()
	
	feet.area_entered.connect(_on_zone_entered)
	feet.area_exited.connect(_on_zone_exited)
	SignalBus.back_to_tile.connect(queue_free)
	set_collision_mask_value(PLATFORM_LAYER, false)
	hitbox.damaged.connect(_on_damaged)
	hp = hp
	pass


#region /// event handlers
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("jump") and velocity.y > 0.0:
		velocity.y *= 0.5
	if event.is_action_pressed("interact"):
		SignalBus.player_interacted.emit(self)
	elif event.is_action_pressed("pause"):
		get_tree().paused = true
		var pause_menu : PauseMenu = load("res://Menus/pause_menu.tscn").instantiate()
		add_child(pause_menu)
		return
	else:
		change_state(current_state.handle_input(event))

func _on_zone_entered(area: Area3D) -> void:
	if area.is_in_group("one_way_trigger"):
		_feet_detectors.append(area)

func _on_zone_exited(area: Area3D) -> void:
	_feet_detectors.erase(area)
#endregion

#region /// running processes
func _process(_delta: float) -> void:
	update_direction()
	check_oneways()
	if direction.x > 0:
		rotation_degrees.y = 90
	if direction.x < 0:
		rotation_degrees.y = -90
	change_state(current_state.process(_delta))

func _physics_process(_delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * _delta
	move_and_slide()
	change_state(current_state.physics_process(_delta))

func update_direction() -> void:
	@warning_ignore("unused_variable")
	var prev_direction : Vector2 = direction
	
	direction = Input.get_vector("left", "right", "up", "down")

func check_oneways() -> void:
	var falling_or_still := velocity.y <= 0.0
	var in_zone := not _feet_detectors.is_empty()
	var should_collide := in_zone and falling_or_still and not wants_drop

	if get_collision_mask_value(PLATFORM_LAYER) != should_collide:
		set_collision_mask_value(PLATFORM_LAYER, should_collide)
#endregion

func has_ability(ability : StringName) -> bool:
	return abilities.get_or_add(ability, false)

func set_abilities() -> void:
	if has_ability(&"high_jump"):
		JUMP_VELOCITY = HIGH_JUMP_VELOCITY
	else:
		print("No abilites")

#region /// State Management
func initialize_states() -> void:
	states = []
	if $States:
		for c in $States.get_children():
			if c is PlayerState:
				states.append(c)
				c.player = self
	
	if states.size() == 0:
		push_warning("no states defined")
		return
	
	for state in states:
		state.init()
	
	change_state(current_state)
	current_state.enter()

func change_state(new_state : PlayerState) -> void:
	if new_state == current_state:
		return
	elif new_state == null:
		return
		
	if current_state:
		current_state.exit()
	
	states.push_front(new_state)
	current_state.enter()
	states.resize(3)

func _on_damaged(attack : Attackbox) -> void:
	if current_state == PlayerStateDeath:
		return
	hp -= attack.damage
	damage_taken.emit()
#endregion
