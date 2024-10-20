extends Node2D

@onready var animation = $chest_animations
@export var wait_time = 1

@onready var turn = %turn
@onready var side = %side

var can_copy:bool = false

var code


func set_address(address):
	$Code.text = "Room Code: " + str(address)
	code = address
func play():
	animation.play('open')
	await get_tree().create_timer(wait_time).timeout
	animation.play('close')

func bop():
	$text_animations.play('bop')


func _on_code_mouse_entered() -> void:
	$Code.text = "Click to Copy"
	can_copy = true


func _on_code_mouse_exited() -> void:
	$Code.text = "Room Code: " + str(code)
	can_copy = false


func _on_press_pressed() -> void:
	DisplayServer.clipboard_set(str(code))
	$Code.text = "Copied!"
