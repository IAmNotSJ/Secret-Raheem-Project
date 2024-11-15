extends Node2D

@onready var currentScene = $"Splash Screen"

func changeScene(target:String, _transition:bool = true):
	var newScene = load(target).instantiate()
	if newScene.name == currentScene.name:
		currentScene.name = currentScene.name + "-OLD"
	add_child(newScene)
	currentScene.queue_free()
	currentScene = newScene
