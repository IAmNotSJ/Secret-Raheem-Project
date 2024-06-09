extends Control

func _unhandled_input(event):
	if event.is_action_pressed("back") and visible:
		hide()


func _on_button_pressed():
	hide()
