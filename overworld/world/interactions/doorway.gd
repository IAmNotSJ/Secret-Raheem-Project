extends Node2D

@export var scene_change:String
@export var save_pos:bool = false

func interact(body):
	Transition.change_scene_to_preset(scene_change)
	body.can_move = false
	
	if save_pos:
		Overworld.save_position(body.position)
