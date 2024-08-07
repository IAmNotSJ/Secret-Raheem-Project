extends Node

@onready var sceneManager = get_tree().root.get_node("SceneManager")

var isWindowFocused:bool = true

const SAVE_PATH = "user://overworld.save"
const SETTINGS_PATH = "user://settings.hellopersonlookingatthefiles"

var rng = RandomNumberGenerator.new()

var settings:Dictionary = {
	"audioSettings" : {"Master":1.0, "Music": 1.0, "SFX": 1.0}
}



var characterInteractions:Dictionary = {
	"Cherry": 0,
	"SJ": 0,
	"Dapper Composty": 0,
	"Dile": 0,
	"Atlas Slime": 0,
	"Cleft": 0,
	"Dizzy": 0,
	"Luna": 0,
	"Block": 0,
	"Cost": 0,
	"Roxy": 0,
	"Byrd": 0,
	"Chu": 0,
	"Nova": 0
}
var items:Dictionary = {
	"Key": false,
	"Pizza": false
}
var unlocks:Dictionary = {
	"Cleft": false,
	"Gate": false
}
var minigames:Dictionary = {
	"Karl Pilkington" : false,
	"Hyena Clicker" : false
}

var costTeleported:bool = false
var tpTimes:int = 0
var octagon_fallen:bool = false

var enteredMiniGameFromMenu = false

func _ready():
	load_save()
	load_settings()
	apply_settings()

func add_interaction(character:String):
	if character == null:
		print("Invalid Character")
	elif characterInteractions.get(character) == null:
		print("Character Does Not Exist!")
	else:
		characterInteractions[character] += 1
		save()

func add_value(daSet, value:String):
	if value == null:
		print("Invalid Character")
	elif daSet.get(value) == null:
		print("Value Does Not Exist!")
	else:
		daSet[value] = true
		save()

func _notification(what):
	match what:
		NOTIFICATION_WM_WINDOW_FOCUS_OUT:
			#print('window unfocused!')
			isWindowFocused = false
		NOTIFICATION_WM_WINDOW_FOCUS_IN:
			#print('window focused!')
			isWindowFocused = true

func save():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	var data:Dictionary = {
		"Character Interactions": characterInteractions,
		"Items" : items,
		"Unlocks" : unlocks,
		"Minigames" : minigames
	}
	var jstr = JSON.stringify(data)
	print('saved!')
	
	file.store_line(jstr)

func load_save():
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return
	if file == null:
		return
	if FileAccess.file_exists(SAVE_PATH) == true:
		if not file.eof_reached():
			var current_line = JSON.parse_string(file.get_line())
			if current_line:
				characterInteractions = current_line["Character Interactions"]
				items = current_line["Items"]
				unlocks = current_line["Unlocks"]
				minigames = current_line["Minigames"]

func save_settings():
	var file = FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	var data:Dictionary = settings
	var jstr = JSON.stringify(data)
	print("settings saved!")
	
	file.store_line(jstr)

func load_settings():
	var file = FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	if not file:
		return
	if file == null:
		return
	if FileAccess.file_exists(SETTINGS_PATH) == true:
		if not file.eof_reached():
			var da_settings = JSON.parse_string(file.get_line())
			if da_settings:
				settings = da_settings
				for key in da_settings.keys():
					if da_settings[key] != null:
						pass

func apply_settings():
	for key in settings["audioSettings"].keys():
		var bus = AudioServer.get_bus_index(key)
		AudioServer.set_bus_volume_db(bus, linear_to_db(settings["audioSettings"][key]))
	print(settings)
