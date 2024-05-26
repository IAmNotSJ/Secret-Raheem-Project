extends ColorRect

var can_draw = false

var brush_color:Color = Color.BLACK
var brush_size:int = 2

var circles = []
var strokes = []
var strokes_special = []

var cur_stroke:Stroke

var stroke_count:int = 0

func _ready():
	DiscordSDKLoader.run_preset("Art")
	cur_stroke = Stroke.new()
	add_child(cur_stroke)

func _process(_delta):
	if Input.is_action_pressed("click") and can_draw:
		if brush_size <= 3:
			cur_stroke.add_circle_advanced(get_local_mouse_position(), brush_size, brush_color)
		else:
			cur_stroke.add_circle(get_local_mouse_position(), brush_size, brush_color)

func _input(event):
	if event.is_action_released("click") and can_draw:
		make_new_stroke()
	if event.is_action_pressed("undo"):
		undo_stroke()
	if event.is_action_pressed('hyena'):
		for i in range(80):
			stroke_count += 1
			circles.push_back([get_local_mouse_position().lerp(Vector2(40, 40), 0.0125 * i), brush_size, brush_color])
			queue_redraw()

func add_circle_advanced(mouse_pos, radius, daColor):
	if stroke_count > 0 and mouse_pos.distance_to(circles[circles.size() - 1][0]) > 4:
			var distance = int(mouse_pos.distance_to(circles[circles.size() - 1][0]))
			var distanceFloat:float = 1
			for i in range(distance):
				stroke_count += 1
				print(distanceFloat / distance * i) 
				circles.push_back([circles[circles.size() - 1][0].lerp(mouse_pos, distanceFloat / distance * i), radius, daColor])
	else:
		stroke_count += 1
		circles.push_back([mouse_pos, radius, daColor])

func add_circle(mouse_pos, radius, daColor):
	stroke_count += 1
	circles.push_back([mouse_pos, radius, daColor])

func draw_circles():
	for i in circles.size():
		draw_circle(circles[i][0], circles[i][1], circles[i][2])

func undo_stroke():
	if strokes_special != []:
		strokes_special.back().queue_free()
		strokes_special.pop_back()
		print(strokes_special)

func clear():
	circles = []
	queue_redraw()

func make_new_stroke():
	strokes.push_back(stroke_count)
	strokes_special.push_back(cur_stroke)
	print(strokes_special)
	#cur_stroke.clear_memory()
	cur_stroke = Stroke.new()
	add_child(cur_stroke)
	cur_stroke.queue_redraw()
	stroke_count = 0

func _on_mouse_detection_mouse_entered():
	can_draw = true
	print('can draw!')

func _on_mouse_detection_mouse_exited():
	can_draw = false
	print("can't draw!")
