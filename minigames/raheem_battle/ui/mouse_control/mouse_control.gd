extends Node2D

@onready var ui = get_parent().get_parent()

var speed:float = 0.2

var enabled:bool = false
var enabled_timer = 3

func _ready():
	ui.turn_ended.connect(_on_turn_ended)
	$change_timer.start()

func _process(delta):
	if enabled and global.isWindowFocused:
		Input.warp_mouse(lerp(get_global_mouse_position(), $FinalPos.global_position, delta * speed))


func _on_change_timer_timeout():
	$FinalPos.global_position = Vector2(randi_range(0, 1280), randi_range(0, 720))
	$change_timer.start()

func _on_turn_ended():
	if enabled_timer > 0:
		enabled_timer -= 1
		if enabled_timer <= 0:
			enabled = false
	
