class_name Dialogue extends Node2D

const dialoguePrefix:String = "res://overworld/dialogue/scripts/"

@export var interaction_dialogue:String = ''

signal interacted

func interact(_body):
	interacted.emit()
