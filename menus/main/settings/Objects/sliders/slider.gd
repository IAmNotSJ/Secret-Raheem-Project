class_name VolumeSlider extends HSlider

@export var setting:String
@export var updateOnMove:bool = false

@export var updating:bool = false

var bus_index

func _ready():
	bus_index = AudioServer.get_bus_index(setting)
	value = db_to_linear(AudioServer.get_bus_volume_db(bus_index))
	$Title.text = setting + " Volume"
	$"Volume Control/Volume".text = str(value * 100) + "%"

func _process(_delta):
	if updating:
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
		$"Volume Control/Volume".text = str(value * 100) + "%"

func _on_drag_started():
	updating = true

func _on_drag_ended(_value_change):
	updating = false
	Saves.audioSettings[AudioServer.get_bus_name(bus_index)] = value
	Saves.save(Saves.SaveTypes.SETTINGS)

