extends CanvasLayer

@onready var hp_bar: TextureProgressBar = %HPBar
@onready var game_over: Control = %GameOver
@onready var load_button: Button = %Load
@onready var quit_button: Button = %Quit



func _ready() -> void:
	SignalBus.player_hp_changed.connect(update_hp_bar)
	game_over.visible = false
	load_button.pressed.connect(_on_load)
	quit_button.pressed.connect(_on_quit)

func update_hp_bar(hp: float, max_hp: float) -> void:
	#TODO: implement handling health containers
	hp_bar.value = hp / max_hp * 100

#region // GameOver
func show_game_over() -> void:
	quit_button.visible = false
	load_button.visible = false
	
	game_over.modulate.a = 0
	game_over.visible = true
	
	var tween = create_tween()
	tween.tween_property(game_over, "modulate", Color.WHITE, 3.0)
	await tween.finished
	
	load_button.visible = true
	quit_button.visible = true
	
	load_button.grab_focus()

func clear_game_over() -> void:
	load_button.visible = false
	quit_button.visible = false
	var player : Player = get_tree().get_first_node_in_group("Player")
	player.queue_free()
	await SceneManager.scene_entered
	game_over.visible = false
	

func _on_load() -> void:
	SaveManager.load_game(SaveManager.current_slot)
	clear_game_over()

func _on_quit() -> void:
	SceneManager.change_scene("uid://bt0ebh28tfngt", "", Vector3.ZERO, "")
	clear_game_over()
