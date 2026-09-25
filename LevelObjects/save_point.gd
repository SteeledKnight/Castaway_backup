@icon("uid://buoq2vb78ds1n")
class_name SavePoint extends Node3D

@onready var area_3d: Area3D = $CSGBox3D/Area3D
@onready var game_saved_label: Label3D = $CSGBox3D/GameSavedLabel


func _ready() -> void:
	area_3d.body_entered.connect(_on_player_entered)
	area_3d.body_exited.connect(_on_player_exited)

func _on_player_entered(_n : Node3D) -> void:
	SignalBus.player_interacted.connect(_on_player_interacted)

func _on_player_exited(_n : Node3D) -> void:
	SignalBus.player_interacted.disconnect(_on_player_interacted)

@warning_ignore("unused_parameter")
func _on_player_interacted(player : Player):
	SaveManager.save_game()
	game_saved_label.visible = true
	Audio.ui_success()
