extends Node2D

@onready var menu = get_parent()

func _unhandled_input(event):
	if visible and event.is_action_pressed("back"):
		visible = false


func _on_hyena_pressed():
	global.enteredMiniGameFromMenu = true
	Transition.change_scene_to_preset("Hyena")


func _on_karl_pressed():
	#menu.get_node("no").play()
	global.enteredMiniGameFromMenu = true
	Transition.change_scene_to_preset("Pilkington")


func _on_paint_pressed():
	menu.get_node("no").play()
	#global.enteredMiniGameFromMenu = true
	#Transition.change_scene_to_preset("Paint")
	
func _on_battle_pressed():
	global.enteredMiniGameFromMenu = true
	Transition.change_scene_to_preset("Battle")


func _on_button_pressed() -> void:
	visible = false
