extends Node2D

@onready var currentScene = $"Splash Screen"

func changeScene(target:String, transition:bool = true):
	var newScene = load(target).instantiate()
	add_child(newScene)
	currentScene.queue_free()
	currentScene = newScene
