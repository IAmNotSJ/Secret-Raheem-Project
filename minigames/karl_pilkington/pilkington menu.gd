extends Node2D


func _unhandled_input(_event: InputEvent):
	if Input.is_action_just_pressed("back"):
		Transition.change_scene_to_file("res://world/main_world.tscn")

func _on_button_pressed():
	Transition.change_scene_to_file("res://minigames/karl_pilkington/karl pilkington.tscn")


func _on_audio_stream_player_finished():
	$AudioStreamPlayer.play()
