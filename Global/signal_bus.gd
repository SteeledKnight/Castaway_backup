extends Node

#TODO: Implement button hints using ControllerIcons plugin
@warning_ignore("unused_signal")
signal player_interacted(player : Player)

@warning_ignore("unused_signal")
signal player_hp_changed(hp : float, max_hp : float)

@warning_ignore("unused_signal")
signal back_to_tile()
