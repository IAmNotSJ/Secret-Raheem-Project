extends Control

func _unhandled_input(event):
	if event.is_action_pressed("back") and visible:
		hide()


func _on_button_pressed():
	hide()

func _ready():
	%VSync.button_pressed = Saves.videoSettings["VSync"]

func _on_v_sync_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Saves.videoSettings["VSync"] = toggled_on
	Saves.save(Saves.SaveTypes.SETTINGS)
