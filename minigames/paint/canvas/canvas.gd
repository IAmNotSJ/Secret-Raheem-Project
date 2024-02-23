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
	if event.is_action_released("click"):
		strokes.push_front(stroke_count)
		print(strokes)
		stroke_count = 0
	if event.is_action_pressed("undo"):
		undo_stroke()
	if event.is_action_pressed('hyena'):
		for i in range(80):
			stroke_count += 1
			circles.push_front([get_global_mouse_position().lerp(Vector2(40, 40), 0.0125 * i), 5, Color.BLACK])
			queue_redraw()

func _draw():
	if Input.is_action_pressed("click"):
		add_circle(get_global_mouse_position(), 2, Color.BLACK)
	draw_circles()

func add_circle_advanced(mouse_pos, radius, daColor):
	if stroke_count > 0 and mouse_pos.distance_to(circles[0][0]) > 4:
			var distance = int(mouse_pos.distance_to(circles[0][0]))
			var distanceFloat:float = 1
			for i in range(distance):
				stroke_count += 1
				print(distanceFloat / distance * i) 
				circles.push_front([circles[0][0].lerp(mouse_pos, distanceFloat / distance * i), radius, daColor])
	else:
		stroke_count += 1
		circles.push_front([mouse_pos, radius, daColor])

func add_circle(mouse_pos, radius, daColor):
	stroke_count += 1
	circles.push_front([mouse_pos, radius, daColor])

func draw_circles():
	for i in circles.size():
		draw_circle(circles[i][0], circles[i][1], circles[i][2])

func undo_stroke():
	if strokes != []:
		for i in range(strokes[0]):
			circles.pop_front()
		strokes.pop_front()
		queue_redraw()

func clear():
	circles = []
	queue_redraw()
