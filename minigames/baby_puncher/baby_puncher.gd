extends Node2D

@onready var animation = $animation

var in_game:bool = false
var timer:float = 0
var punches:int = 0

func _process(delta: float) -> void:
	if in_game:
		timer += delta
		%timer.text = str("%.2f" % (20 - timer)) + " seconds"
	if timer >= 20:
		_on_timer_ended()

func _on_timer_ended():
	in_game = false
	timer = 0
	$total.text = "You punched the baby " + str(punches) + " times! Good job!"
	$detection.visible = false
	$punch.visible = false
	$total.visible = true
	$restart.visible = true

func _on_detection_pressed() -> void:
	animation.stop()
	animation.play("shake")
	punches += 1
	%Dumbass.play("hit" + str(randi_range(1, 6)))


func _on_start_pressed() -> void:
	punches = 0
	timer = 0
	
	$title.visible = false
	
	$restart.visible = false
	$total.visible = false
	$start.visible = false
	$punch.visible = true
	$detection.visible = true
	in_game = true
