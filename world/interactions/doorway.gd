extends Node2D

@export var scene_change:String

func interact(_body):
	Transition.change_scene_to_file(scene_change)
