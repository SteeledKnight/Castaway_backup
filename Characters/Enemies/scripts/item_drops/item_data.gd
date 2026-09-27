class_name ItemData extends Resource

@export_file("*.tscn") var item : String
@export var minimum_quantity : int = 1
@export var maximum_quantity : int = 1
#default is 100% drop rate
@export var drop_chance : float = 0.25
