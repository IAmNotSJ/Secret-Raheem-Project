extends ColorRect

var circles = []
var strokes = []

var stroke_count:int = 0

func _ready():
	DiscordSDKLoader.run_preset("Art")

func _process(_delta):
	if Input.is_action_pressed("click"):
		if circles != []:
			if get_global_mouse_position().distance_to(circles[0][0]) > 1:
				queue_redraw()
		else:
			queue_redraw()

func _input(event):
	if event is InputEventMouseMotion:
		print('guh')
	if event.is_action_released("click"):
		strokes.push_front(stroke_count)
		print(strokes)
		stroke_count = 0
	if event.is_action_pressed("undo"):
		undo_stroke()

func _draw():
	if Input.is_action_pressed("click"):
		add_circle(get_global_mouse_position(), 2, Color.BLACK)

func add_circle(mouse_pos, radius, daColor):
	stroke_count += 1
	circles.push_front([mouse_pos, radius, daColor])
	for i in circles.size():
		draw_circle(circles[i][0], circles[i][1], circles[i][2])

func undo_stroke():
	for i in range(strokes[0]):
		circles.pop_front()
	strokes.pop_front()
	queue_redraw()

func clear():
	circles = []
	queue_redraw()
