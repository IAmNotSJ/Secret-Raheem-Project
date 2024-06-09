extends Node2D

# # # # # # # # # # # # # # # #
# MAIN SCENE FOR DA OVERWORLD #
# # # # # # # # # # # # # # # #

# All overworld scenes will be loaded into this scene
# TODO: figure out how dafuq to actually make child overworld scenes

var characterString = "res://overworld/characters/wibr/wibr.tscn"
var sceneString = "res://overworld/world/areas/secret/secretWorld.tscn"

var scene
var character

func _ready():
	scene = load(sceneString).instantiate()
	add_child(scene)
	
	scene.assign_character(characterString)
