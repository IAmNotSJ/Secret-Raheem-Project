class_name Dialogue extends Node2D

@export var interaction_dialogue:String = ''

signal interacted

func interact(_body):
	interacted.emit()
	DialogueManager.show_dialogue_balloon(load(interaction_dialogue), "start")
