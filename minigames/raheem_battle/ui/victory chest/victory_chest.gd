extends Node2D

@onready var ui = get_parent()

@onready var animation = $chest_animations
@export var wait_time = 1

@onready var turn = %turn
@onready var side = %side

var can_copy:bool = false

var game_down:bool

var is_down:bool = false

var code


func _process(_delta):
	ui.card_hand.victory_chest.global_position.y = $chest.global_position.y - 30

func set_address(address):
	%Code.text = "Room Code: " + str(address)
	code = address
func play():
	var was_down = is_down
	if !is_down:
		animation.play("down")
		is_down = true
		game_down = true
		await animation.animation_finished
	open()
	await get_tree().create_timer(wait_time).timeout
	close()
	await animation.animation_finished
	if !was_down:
		animation.play("up")
	is_down = false
	await animation.animation_finished
	game_down = false

func bop():
	$text_animations.play('bop')


func _on_code_mouse_entered() -> void:
	%Code.text = "Click to Copy"
	can_copy = true


func _on_code_mouse_exited() -> void:
	%Code.text = "Room Code: " + str(code)
	can_copy = false


func _on_press_pressed() -> void:
	DisplayServer.clipboard_set(str(code))
	%Code.text = "Copied!"


func _on_dropdown_pressed() -> void:
	if is_down:
		animation.play('up')
		is_down = false
		%Dropdown.text = "v"
	else:
		animation.play('down')
		is_down = true
		%Dropdown.text = "^"

func _on_chest_detection_toggled(toggled_on: bool) -> void:
	if toggled_on:
		open()
	else:
		close()

func open():
	animation.play('open')
	ui.card_hand.show_victory_chest_cards($chest.global_position)

func close():
	animation.play('close')
	ui.card_hand.hide_victory_chest_cards($chest.global_position)
