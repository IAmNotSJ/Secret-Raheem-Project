class_name OverworldCharacter extends Sprite2D

@export var character_name:String = ''
@export var interaction_dialogue:String = ''

func interact(_body):
	DialogueManager.show_dialogue_balloon(load(interaction_dialogue), "start")
