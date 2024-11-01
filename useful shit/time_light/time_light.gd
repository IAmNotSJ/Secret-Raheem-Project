extends PointLight2D

@export var starting_hour:int = 0
@export var starting_minute:int = 0

@export var ending_hour:int = 0
@export var ending_minute:int = 0

func _ready():
	Overworld.time_tick.connect(_on_time_tick)
	
	if Overworld.is_time_between(starting_hour, starting_minute, ending_hour, ending_minute):
		visible = true
	else:
		visible = false

func _on_time_tick(hour, minute):
	if starting_hour == hour && starting_minute == minute:
		visible = true
	if ending_hour == hour && ending_minute == minute:
		visible = false
