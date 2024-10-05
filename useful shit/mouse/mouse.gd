extends Sprite2D

enum MouseMode {
	VISIBLE,
	HIDDEN
}
enum MouseType {
	RAHEEM,
	WIBR
}

var outside_bounds:bool = false
var mouse_mode:MouseMode :
	set(value):
		mouse_mode = value
		if !outside_bounds:
			if mouse_mode == MouseMode.VISIBLE:
				visible = true
			else:
				visible = false
var mouse_mode_suffix:String = ""



var mouse_type:MouseType:
	set(value):
		mouse_type = value
		change_mouse_type(mouse_type)

func _ready():
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_HIDDEN)
	#mouse_type = MouseType.WIBR
	visible = false

func _input(event):
	global_position = get_global_mouse_position()
	
	if event.is_action_pressed("click"):
		$AnimationPlayer.play("click")
	if event.is_action_released("click"):
		$AnimationPlayer.play("release")


func _notification(what):
	if what == NOTIFICATION_WM_MOUSE_ENTER:
		outside_bounds = false
		if mouse_mode == MouseMode.VISIBLE:
			visible = true
	elif what == NOTIFICATION_WM_MOUSE_EXIT:
		visible = false
		outside_bounds = true

func make_visible():
	mouse_mode = MouseMode.VISIBLE

func make_hidden():
	mouse_mode = MouseMode.HIDDEN

func change_mouse_type(type:MouseType):
	match type:
		MouseType.RAHEEM:
			texture = load("res://useful shit/mouse/mouse-special.png")
			hframes = 5
			mouse_mode_suffix = ""
		MouseType.WIBR:
			texture = load("res://useful shit/mouse/wibr.png")
			hframes = 1
			mouse_mode_suffix = "_single"
