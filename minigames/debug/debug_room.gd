extends Node2D


func _ready():
	Overworld.time_tick.connect(_on_time_tick)
	_on_time_tick(Overworld.get_current_hour(), Overworld.get_current_minutes())

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed('back'):
		Transition.change_scene_to_preset("Main Menu")

func _on_time_tick(hour:int, minute:int):
	var new_string:String
	var pm:bool = false
	
	if hour > 12:
		hour -= 12
		new_string = str(hour) + ":" + str(minute) + " PM"
	else:
		new_string = str(hour) + ":" + str(minute) + " AM"
	$time.text = new_string


func _on_hour_value_changed(value: float) -> void:
	Overworld.set_time(value * 60 * 60 + %MINUTES.value * 60)


func _on_minutes_value_changed(value: float) -> void:
	Overworld.set_time(%HOUR.value * 60 * 60 + value * 60)
