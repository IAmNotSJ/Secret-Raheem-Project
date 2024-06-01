extends Node

const MINUTES_PER_HOUR = 60
const MINUTES_PER_DAY = 24 * MINUTES_PER_HOUR
const INGAME_TO_REAL_MINUTE_DURATION = (2*PI) / MINUTES_PER_DAY

signal time_tick(hour:int, minute:int)

var time:float = 0
var past_minute:float = 1.0

var initial_hour
var initial_minute

const INGAME_SPEED:float = 1 / 60

func _ready():
	initial_hour = int(Time.get_time_dict_from_system()["hour"])
	initial_minute = int(Time.get_time_dict_from_system()["minute"])
	
	time = INGAME_TO_REAL_MINUTE_DURATION * initial_hour * MINUTES_PER_HOUR + INGAME_TO_REAL_MINUTE_DURATION * initial_minute 
func _process(delta):
	time += delta * INGAME_TO_REAL_MINUTE_DURATION * INGAME_SPEED
	
	recalculate_time()

func recalculate_time():
	var total_minutes = int(time / INGAME_TO_REAL_MINUTE_DURATION)
	
	var current_day_minutes = total_minutes % MINUTES_PER_DAY
	var hour = int(current_day_minutes / MINUTES_PER_HOUR)
	var minute = int(current_day_minutes % MINUTES_PER_HOUR)
	
	if past_minute != minute:
		past_minute = minute
		time_tick.emit(hour, minute)
		if hour > 12:
			print(str(hour - 12) + ":" + str(minute) + " PM")
		else:
			print(str(hour) + ":" + str(minute) + " AM")

var positions:Dictionary = {
	"Main World" : Vector2(0, 0),
	"Key House" : Vector2(0, 0),
	"Apartment" : Vector2(0, 0),
	"Pizzeria" : Vector2(0, 0),
}

func save_position(position):
	positions["Main World"] = position
