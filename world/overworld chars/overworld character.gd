class_name OverworldCharacter extends Sprite2D

@export var character_name:String = ''
@export var interaction_dialogue:String = ''

func openDialogue():
	DialogueManager.show_dialogue_balloon(load(interaction_dialogue), "start")
