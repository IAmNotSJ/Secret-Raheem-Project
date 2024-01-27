class_name OverworldCharacter extends Sprite2D

@export var interaction_dialogue:String = ''

signal interacted

func interact(_body):
	DialogueManager.show_dialogue_balloon(load(interaction_dialogue), "start")
	interacted.emit()
