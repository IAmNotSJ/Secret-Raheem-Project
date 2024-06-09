extends OptionButton

func _ready():
	update()
func update():
	selected = DisplayServer.window_get_mode()
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_MAXIMIZED:
		selected = DisplayServer.WINDOW_MODE_WINDOWED

func _on_item_selected(index):
	match index:
		0:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			get_window().size = Vector2i(1280, 720)
		1:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
