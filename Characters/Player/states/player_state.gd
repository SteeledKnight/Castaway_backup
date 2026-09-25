@icon("uid://dje1bgkgl8hfb")
class_name PlayerState extends Node

var player : Player
var next_state : PlayerState

#region // state references
@onready var idle: PlayerStateIdle = %Idle
@onready var run: PlayerStateRun = %Run
@onready var jump: PlayerStateJump = %Jump
@onready var fall: PlayerState = %Fall
@onready var crouch: PlayerStateCrouch = %Crouch
@onready var attack: PlayerStateAttack = %Attack
@onready var damaged: PlayerStateDamaged = %Damaged
@onready var death: PlayerStateDeath = %Death
#endregion

func init() -> void:
	pass


func enter() -> void:
	pass


func exit() -> void:
	pass


func handle_input(_event: InputEvent) -> PlayerState:
	return next_state


func process(_delta: float) -> PlayerState:
	return next_state


func physics_process(_delta: float) -> PlayerState:
	return next_state
