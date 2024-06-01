class_name Stroke extends Node2D

var circles = []
#Circles added with add_circle_advanced(). Not to be used in calculations for add_circle_advanced()
var circles_advanced = []
var size:int = 0

var brush_size:int = 2
var brush_color:Color = Color.BLACK
func _draw():
	draw_circles()

func add_circle(mouse_pos, radius, daColor):
	size += 1
	circles.push_back([mouse_pos, radius, daColor])
	queue_redraw()

func add_circle_advanced(mouse_pos, radius, daColor):
	if size > 0 and mouse_pos.distance_to(circles[circles.size() - 1][0]) > 4:
		var distance = int(mouse_pos.distance_to(circles[circles.size() - 1][0]))
		var distanceFloat:float = 1
		for i in range(distance - 1):
			size += 1
			circles_advanced.push_back([circles[circles.size() - 1][0].lerp(mouse_pos, distanceFloat / distance * i), radius, daColor])
		circles.push_back([mouse_pos, radius, daColor])
	else:
		size += 1
		circles.push_back([mouse_pos, radius, daColor])
	queue_redraw()

func draw_circles():
	for i in circles.size():
		draw_circle(circles[i][0], circles[i][1], circles[i][2])
	for i in circles_advanced.size():
		draw_circle(circles_advanced[i][0], circles_advanced[i][1], circles_advanced[i][2])
