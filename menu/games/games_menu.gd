extends Node2D

func _unhandled_input(event):
	if visible and event.is_action_pressed("back"):
		visible = false


func _on_hyena_pressed():
	global.enteredMiniGameFromMenu = true
	Transition.change_scene_to_preset("Hyena")


func _on_karl_pressed():
	global.enteredMiniGameFromMenu = true
	Transition.change_scene_to_preset("Pilkington")


func _on_paint_pressed():
	global.enteredMiniGameFromMenu = true
	Transition.change_scene_to_preset("Paint")
