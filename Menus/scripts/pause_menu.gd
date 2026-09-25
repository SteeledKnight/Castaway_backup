class_name PauseMenu extends CanvasLayer

@onready var settings: Control = $Control/Settings
@onready var map: Control = %Map

@onready var settings_button: Button = %SettingsButton
@onready var back: Button = %Back
@onready var quit: Button = %Quit
@onready var music_slider: HSlider = %MusicSlider
@onready var sfx_slider: HSlider = %SFXSlider
@onready var ui_slider: HSlider = %UISlider

#abilities
@onready var high_jump: TextureRect = %HighJump
@onready var ability_2: TextureRect = %Ability2
@onready var ability_3: TextureRect = %Ability3
@onready var ability_4: TextureRect = %Ability4

var player : Player


func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	get_abilities()
	show_map()
	settings_button.pressed.connect(show_settings)
	Audio.setup_button_audio(self)
	setup_settings_menu()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		get_viewport().set_input_as_handled()
		get_tree().paused = false
		queue_free()
	if map.visible == true:
		if event.is_action_pressed("down") or event.is_action_pressed("right"):
			settings_button.grab_focus()
	pass


func setup_settings_menu() -> void:
	music_slider.value = AudioServer.get_bus_volume_linear(2)
	sfx_slider.value = AudioServer.get_bus_volume_linear(3)
	ui_slider.value = AudioServer.get_bus_volume_linear(4)
	
	music_slider.value_changed.connect(_music_slider_changed)
	sfx_slider.value_changed.connect(_sfx_slider_changed)
	ui_slider.value_changed.connect(_ui_slider_changed)
	
	back.pressed.connect(show_map)
	quit.pressed.connect(_quit_pressed)

func _quit_pressed() -> void:
	#free player
	#transition to title
	SceneManager.change_scene("uid://bt0ebh28tfngt", "", Vector2.ZERO, "")
	SaveManager.save_config()
	get_tree().paused = false
	SignalBus.back_to_tile.emit()
	queue_free()

func show_map() -> void:
	map.visible = true
	settings.visible = false
	Audio.ui_select()
	SaveManager.save_config()

func show_settings() -> void:
	map.visible = false
	settings.visible = true
	Audio.ui_select()
	SaveManager.save_config()
	back.grab_focus()

func get_abilities() -> void:
	if player.has_ability(&"high_jump"):
		high_jump.visible = true

#region /// Audio handlers
func _music_slider_changed(v : float) -> void:
	AudioServer.set_bus_volume_linear(2, v)

func _sfx_slider_changed(v : float) -> void:
	AudioServer.set_bus_volume_linear(3, v)
	Audio.play_spatial_sound(Audio.ui_focus_audio, Vector3.ZERO)

func _ui_slider_changed(v : float) -> void:
	AudioServer.set_bus_volume_linear(4, v)
	Audio.ui_focus()
#endregion
