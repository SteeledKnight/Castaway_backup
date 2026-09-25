extends CanvasLayer

#region /// onready varialbles
@onready var main_menu: VBoxContainer = %MainMenu
@onready var new_game_menu: VBoxContainer = %NewGameMenu
@onready var load_game_menu: VBoxContainer = %LoadGameMenu

@onready var new_game: Button = %NewGame
@onready var load_game: Button = %LoadGame

@onready var new_slot_1: Button = %NewSlot1
@onready var new_slot_2: Button = %NewSlot2
@onready var new_slot_3: Button = %NewSlot3

@onready var load_slot_1: Button = %LoadSlot1
@onready var load_slot_2: Button = %LoadSlot2
@onready var load_slot_3: Button = %LoadSlot3

@onready var new_game_back: Button = %NewGameBack
@onready var load_game_back: Button = %LoadGameBack
#endregion


func _ready() -> void:
	new_game.pressed.connect(show_new_game_menu)
	load_game.pressed.connect(show_load_game_menu)
	
	new_slot_1.pressed.connect(_new_game_pressed.bind(0))
	new_slot_2.pressed.connect(_new_game_pressed.bind(1))
	new_slot_3.pressed.connect(_new_game_pressed.bind(2))
	
	load_slot_1.pressed.connect(_load_game_pressed.bind(0))
	load_slot_2.pressed.connect(_load_game_pressed.bind(1))
	load_slot_3.pressed.connect(_load_game_pressed.bind(2))
	
	Audio.setup_button_audio(self)
	
	show_main_menu()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if main_menu.visible == false:
			show_main_menu()

func show_main_menu() -> void:
	main_menu.visible = true
	new_game_menu.visible = false
	load_game_menu.visible = false
	
	new_game.grab_focus()

func show_new_game_menu() -> void:
	main_menu.visible = false
	new_game_menu.visible = true
	load_game_menu.visible = false
	
	new_slot_1.grab_focus()
	
	if SaveManager.save_file_exists(0):
		new_slot_1.text = "Replace Slot 1"
	if SaveManager.save_file_exists(1):
		new_slot_2.text = "Replace Slot 2"
	if SaveManager.save_file_exists(2):
		new_slot_3.text = "Replace Slot 3"
	
	new_game_back.pressed.connect(show_main_menu)

func show_load_game_menu() -> void:
	main_menu.visible = false
	new_game_menu.visible = false
	load_game_menu.visible = true
	
	load_slot_1.grab_focus()
	
	load_slot_1.disabled = not SaveManager.save_file_exists(0)
	load_slot_2.disabled = not SaveManager.save_file_exists(1)
	load_slot_3.disabled = not SaveManager.save_file_exists(2)
	
	load_game_back.pressed.connect(show_main_menu)

func _new_game_pressed(slot : int) -> void:
	SaveManager.new_game(slot)
	SceneManager.change_scene("uid://ce7k1l2k0sl0t", "", Vector3.ZERO, "TOP")
	Audio.fade_out(Audio.get_music_player(Audio.current_track))
	
func _load_game_pressed(slot : int) -> void:
	SaveManager.load_game(slot)
	
	
