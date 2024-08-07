extends ColorRect

@onready var save_dialog = $SaveDialog

var can_draw = false

var brush_color:Color = Color.BLACK
var brush_size:int = 2

var circles = []
var strokes = []
var strokes_special = []

var cur_stroke:Stroke

var stroke_count:int = 0

var use_advanced:bool = true

func _ready():
	DiscordSDKLoader.run_preset("Art")
	cur_stroke = Stroke.new()
	
	save_dialog.add_filter("*.png", "Image")
	
	add_child(cur_stroke)

func _process(_delta):
	if Input.is_action_pressed("click") and can_draw:
		if brush_size <= 3:
			if use_advanced:
				cur_stroke.add_circle_advanced(get_local_mouse_position(), brush_size, brush_color)
			else:
				cur_stroke.add_circle(get_local_mouse_position(), brush_size, brush_color)
		else:
			cur_stroke.add_circle(get_local_mouse_position(), brush_size, brush_color)

func _input(event):
	if event.is_action_released("click") and can_draw:
		make_new_stroke()
	if event.is_action_pressed("undo"):
		undo_stroke()
	if event.is_action_pressed("save"):
		save_dialog.popup_centered()
	if event.is_action_pressed("hyena"):
		if use_advanced:
			use_advanced = false
		else:
			use_advanced = true

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
	queue_redraw()

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


func _on_save_dialog_file_selected(path):
	var isMaximized:bool = false
	if DisplayServer.window_get_mode(DisplayServer.WINDOW_MODE_MAXIMIZED):
		isMaximized = true
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	# Wait until the frame has finished before getting the texture.
	await RenderingServer.frame_post_draw
	# Get the viewport image.
	var img = get_viewport().get_texture().get_image()
	# Crop the image so we only have canvas area.
	var cropped_image = img.get_region(Rect2(global_position, size))
	# Save the image with the passed in path we got from the save dialog.
	cropped_image.save_png(path + ".png")
	
	if isMaximized:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
