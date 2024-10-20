extends Node2D

func _ready():
	if randi_range(1, 1000) == 1:
		$Logo.texture = load("res://useful shit/splash/assets/jeff.png")
		$bg.visible = true
func _unhandled_input(event):
	if event.is_pressed():
		$AnimationPlayer.stop()
		changeScene()

func changeScene():
	Transition.change_scene_to_preset("Main Menu", false)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
	get_window().size = Vector2i(1280, 720)
