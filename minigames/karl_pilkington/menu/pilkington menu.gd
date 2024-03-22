extends Node2D

@onready var parent = global.sceneManager.get_node("Pilkington")

func _ready():
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_VISIBLE)
	if !global.minigames["Karl Pilkington"]:
		global.minigames["Karl Pilkington"] = true
		global.save()
	DiscordSDKLoader.run_preset("Karl")
func _unhandled_input(_event: InputEvent):
	if Input.is_action_just_pressed("back"):
		if global.enteredMiniGameFromMenu:
			Transition.change_scene_to_preset("Main Menu")
		else:
			Transition.change_scene_to_file("res://world/key house/key_house.tscn")

func _on_button_pressed():
	parent.changeScene("res://minigames/karl_pilkington/select menu/upgrade_menu.tscn")
	#DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_HIDDEN)


func _on_audio_stream_player_finished():
	$AudioStreamPlayer.play()
