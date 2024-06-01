extends Node2D

@onready var canvas = $Canvas


func _on_color_picker_button_color_changed(color):
	$Canvas.brush_color = color


func _on_brush_size_drag_ended(_daVal):
	$Canvas.brush_size = $"Buttons/Brush Size".value

