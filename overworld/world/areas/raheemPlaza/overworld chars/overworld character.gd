class_name OverworldCharacter extends Sprite2D

const dialoguePrefix:String = "res://overworld/dialogue/scripts/"

@export var interaction_dialogue:String = ''

signal interacted

func interact(_body):
	DialogueManager.show_dialogue_balloon(load(dialoguePrefix + interaction_dialogue + ".dialogue"), "start")
	interacted.emit()
