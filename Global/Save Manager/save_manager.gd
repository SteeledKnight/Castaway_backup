extends Node

@export var new_game_scene_path : String = "uid://ce7k1l2k0sl0t"

const CONFIG_FILE = "user://prefs.ini"
const SLOTS : Array[String] = [
	"user://0.sav", "user://1.sav", "user://2.sav"
]

var current_slot : int = 0
var save_data : Dictionary
var discovered_areas :  Array = []
var inventory : Dictionary = {}
var abilities : Dictionary = {
	&"high_jump" : false
}
var persistent_data : Dictionary = {}


func _ready() -> void:
	SceneManager.scene_entered.connect(_on_scene_entered)
	load_config()

#region /// save management

func new_game(slot : int) -> void:
	current_slot = slot
	discovered_areas.clear()
	persistent_data.clear()
	discovered_areas.append(new_game_scene_path)
	save_data = {
		"current_scene" : new_game_scene_path,
		"hp" : 10,
		"max_hp" : 10,
		"inventory" : inventory,
		"abilities" : abilities,
		"discovered_areas" : discovered_areas,
		"persistent_data" : persistent_data,
	}
	
	var save_file = FileAccess.open(SLOTS[0], FileAccess.WRITE)
	save_file.store_line(JSON.stringify(save_data))
	
	save_file.close()
	load_game(slot)
	


func save_game() -> void:
	var player : Player = get_tree().get_first_node_in_group("Player")
	save_data = {
		#TODO: update to get current scene from SceneManager
		"current_scene" : get_tree().root.scene_file_path,
		"hp" : player.hp,
		"max_hp" : player.max_hp,
		"inventory" : player.inventory,
		"abilities" : player.abilities,
		"discovered_areas" : discovered_areas,
		"persistent_data" : persistent_data,
	}
	var save_file = FileAccess.open(SLOTS[0], FileAccess.WRITE)
	save_file.store_line(JSON.stringify(save_data))


func load_game(slot : int) -> void:
	current_slot = slot
	var save_file = FileAccess.open(SLOTS[0], FileAccess.READ)
	if save_file == null:
		push_warning("No save file exists")
		return
	save_data = JSON.parse_string(save_file.get_line())
	
	persistent_data = save_data.get("persistent_data", {})
	discovered_areas = save_data.get("discovered_areas", {})
	var scene_path : String = save_data.get("current_scene", "uid://ce7k1l2k0sl0t")
	SceneManager.change_scene(scene_path, "", Vector3.ZERO, "TOP")
	setup_player()
#endregion

func setup_player() -> void:
	var player : Player = null
	while not player:
		await get_tree().process_frame
		player = get_tree().get_first_node_in_group("Player")
	player.hp = save_data.get("hp", 10)
	player.max_hp = save_data.get("max_hp", 10)
	player.inventory = save_data.get("inventory", {})
	player.abilities = save_data.get("abilities", {})
	#need to get these from somewhere else
	#player.discovered_areas = save_data.get("discovered_areas", {})
	#player.persistent_data = save_data.get("persistent_data", {})

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("save_game"):
		if FileAccess.open(SLOTS[0], FileAccess.READ) == null:
			new_game(current_slot)
		else:
			save_game()
		new_game(current_slot)
	if event.is_action_pressed("load_game"):
		load_game(current_slot)

func save_file_exists(slot : int) -> bool:
	return FileAccess.file_exists(SLOTS[slot])

func is_area_discovered(scene_uid) -> bool:
	return discovered_areas.has(scene_uid)

func _on_scene_entered(scene_uid) -> void:
	if discovered_areas.has(scene_uid):
		return
	else:
		discovered_areas.append(scene_uid)

#region /// persistent Config options
func save_config() -> void:
	var config := ConfigFile.new()
	config.set_value("audio", "music", AudioServer.get_bus_volume_linear(2))
	config.set_value("audio", "sfx", AudioServer.get_bus_volume_linear(3))
	config.set_value("audio", "ui", AudioServer.get_bus_volume_linear(4))
	config.save(CONFIG_FILE)
	pass

func load_config() -> void:
	var config := ConfigFile.new()
	var err = config.load(CONFIG_FILE)
	
	if err != OK:
		AudioServer.set_bus_volume_linear(2, 0.7)
		AudioServer.set_bus_volume_linear(3, 0.7)
		AudioServer.set_bus_volume_linear(4, 0.7)
		save_config()
		return
	
	AudioServer.set_bus_volume_linear(2, config.get_value("audio", "music", 0.7))
	AudioServer.set_bus_volume_linear(3, config.get_value("audio", "sfx", 0.7))
	AudioServer.set_bus_volume_linear(4, config.get_value("audio", "ui", 0.7))
