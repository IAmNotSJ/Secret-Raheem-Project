extends Sprite2D

const MINUTES_PER_DAY:float = 1440

var height:float = texture.get_height() - 720


func _ready():
	if !Saves.battle_settings["DayNight"]:
		offset.y = -4000
	else:
		Overworld.time_tick.connect(_on_time_tick)
		_on_time_tick(Overworld.get_current_hour(), Overworld.get_current_minutes())

func _on_time_tick(hour, minute):
	var minutes:float = (hour * 60) + minute
	var minute_ratio = minutes / MINUTES_PER_DAY
	
	offset.y = -height * minute_ratio
