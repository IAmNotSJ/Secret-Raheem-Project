class_name OverworldArea extends Node2D

@export_category("Character Conditions")
@export var forcedCharacterPath:String
@export var camFollowCharacter:bool = true

var character

func assign_character(characterPath:String):
	print('yo what')
	if forcedCharacterPath == null:
		character = load(characterPath).instantiate()
		add_child(character)
