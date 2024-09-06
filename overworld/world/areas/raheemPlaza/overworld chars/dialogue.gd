class_name Dialogue extends Node2D

const dialoguePrefix:String = "res://overworld/dialogue/scripts/overworld/"
@export var interaction_dialogue:String = ''

signal interacted

func interact(_body):
	interacted.emit()
	Dialogic.Inputs.auto_advance.enabled_forced = false
	Dialogic.start(dialoguePrefix + interaction_dialogue + '.dtl')
