extends Node2D

@onready var parent = global.sceneManager.get_node("Pilkington")

func _unhandled_input(event):
	if event.is_action_pressed("back"):
		parent.changeScene("res://minigames/karl_pilkington/menu/pilkington menu.tscn")
