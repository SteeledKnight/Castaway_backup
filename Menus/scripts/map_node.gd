@tool
@icon("uid://bvsih7glajddr")
class_name map_node extends Control

const SCALE_FACTOR : float = 6

@export_file("*.tscn") var linked_scene : String : set = _on_scene_set
@export_tool_button("Update") var update_node_action = update_node

@export var entrances_top: Array[float] = []
@export var entrances_right: Array[float] = []
@export var entrances_bottom: Array[float] = []
@export var entrances_left: Array[float] = []

var indicator_offset := Vector2.ZERO

@onready var level_name: Label = $LevelName
@onready var transition_blocks: Control = %TransitionBlocks

func _ready() -> void:
	if Engine.is_editor_hint():
		pass
	else:
		level_name.queue_free()
		create_transition_blocks()
		if not SaveManager.is_area_discovered(linked_scene):
			visible = false
		elif SceneManager.current_scene_uid == linked_scene:
			display_player_location()
		Audio.setup_button_audio(self)

func _on_scene_set(value : String) -> void:
	if linked_scene != value:
		linked_scene = value
		if Engine.is_editor_hint():
			update_node()

func update_node() -> void:
	var new_size := Vector2(8 * SCALE_FACTOR, 4 * SCALE_FACTOR)
	var transitions : Array[LevelTransition] = []
	entrances_top.clear()
	entrances_left.clear()
	entrances_right.clear()
	entrances_bottom.clear()
	
	if ResourceLoader.exists(linked_scene):
		var packed_scene : PackedScene = ResourceLoader.load(linked_scene) as PackedScene
		if packed_scene:
			var instance = packed_scene.instantiate()
			if instance:
				update_node_label(instance)
				for c in instance.get_children():
					if c is LevelBounds:
						new_size = Vector2(c.width, c.height)
						indicator_offset = Vector2(c.position.x, c.position.y)
					elif c is LevelTransition:
						transitions.append(c)
				instance.queue_free()
	size = new_size * SCALE_FACTOR
	create_entrance_data(transitions)
	create_transition_blocks()

func create_entrance_data(transistions : Array[LevelTransition]) -> void:
	for t in transistions:
		if t.location == LevelTransition.SIDE.LEFT:
			var offset := clampf(
				self.size.y / 2 + ((t.global_position.y - indicator_offset.y) * SCALE_FACTOR),
				2.0,
				self.size.y - 4.0
			)
			entrances_left.append(offset)
		elif t.location == LevelTransition.SIDE.RIGHT:
			var offset := clampf(
				self.size.y / 2 + ((t.global_position.y - indicator_offset.y) * SCALE_FACTOR),
				2.0,
				self.size.y - 4.0
			)
			entrances_right.append(offset)
		elif t.location == LevelTransition.SIDE.TOP:
			var offset := clampf(
				self.size.x / 2 + ((t.global_position.x - indicator_offset.x) * SCALE_FACTOR),
				2.0,
				self.size.x - 4.0
			)
			entrances_top.append(offset)
		elif t.location == LevelTransition.SIDE.BOTTOM:
			var offset := clampf(
				self.size.x / 2 + ((t.global_position.x - indicator_offset.x) * SCALE_FACTOR),
				2.0,
				self.size.x - 4.0
			)
			entrances_bottom.append(offset)

func create_transition_blocks() -> void:
	if not transition_blocks:
		transition_blocks = %TransitionBlocks
	
	for c in transition_blocks.get_children():
		c.queue_free()
	
	for t in entrances_left:
		var block := add_block()
		block.size.y = 6
		block.position.x = 0
		block.position.y = t - 6
	for t in entrances_right:
		var block := add_block()
		block.size.y = 6
		block.position.x = self.size.x - 2
		block.position.y = t - 6
	for t in entrances_top:
		var block := add_block()
		block.size.x = 6
		block.position.y = 0
		block.position.x = t - 6
	for t in entrances_bottom:
		var block := add_block()
		block.size.y = 6
		block.position.y = self.size.y - 2
		block.position.x = t - 6

func add_block() -> ColorRect:
	var block := ColorRect.new()
	block.color = Color.YELLOW
	transition_blocks.add_child(block)
	block.custom_minimum_size = Vector2(2.0, 2.0)
	return block

func update_node_label(scene : Node) -> void:
	if not level_name:
		level_name = $LevelName
	var text : String = scene.name
	level_name.text = text
	
func display_player_location() -> void:
	var player : Player = get_tree().get_first_node_in_group("Player")
	var i : Control = %PlayerIndicator
	var pos : Vector2 = position
	pos += Vector2( (self.size.x / 2 + (player.global_position.x - indicator_offset.x) * SCALE_FACTOR) , (self.size.y / 2 - (player.global_position.y - indicator_offset.y) * SCALE_FACTOR) )
	i.position = pos
