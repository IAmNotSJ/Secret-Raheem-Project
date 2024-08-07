extends Node

enum SaveTypes {
	SETTINGS,
	OVERWORLD,
	HYENA,
	PILKINGTON,
	PAINT,
	BATTLE
}
const PATH_OVERWORLD = "user://overworld.save"
const PATH_SETTINGS = "user://settings.hellopersonlookingatthefiles"

var audioSettings:Dictionary = {
	"Master":1.0, 
	"Music": 1.0, 
	"SFX": 1.0
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

func _ready():
	load_save(SaveTypes.OVERWORLD)
	load_save(SaveTypes.SETTINGS)

func save(type:SaveTypes):
	var PATH:String = ""
	match type:
		SaveTypes.OVERWORLD:
			PATH = PATH_OVERWORLD
		SaveTypes.SETTINGS:
			PATH = PATH_SETTINGS
	var file = FileAccess.open(PATH, FileAccess.WRITE)
	var data:Dictionary
	match type:
		SaveTypes.OVERWORLD:
			data = {
				"Character Interactions": characterInteractions,
				"Items" : items,
				"Unlocks" : unlocks,
				"Minigames" : minigames
			}
		SaveTypes.SETTINGS:
			data = {
				"Audio Settings" : audioSettings
			}
	var jstr = JSON.stringify(data)
	print('saved!')
	
	file.store_line(jstr)

func load_save(type:SaveTypes):
	var PATH:String = ""
	match type:
		SaveTypes.OVERWORLD:
			PATH = PATH_OVERWORLD
		SaveTypes.SETTINGS:
			PATH = PATH_SETTINGS
	var file = FileAccess.open(PATH, FileAccess.READ)
	if not file:
		return
	if file == null:
		return
	if FileAccess.file_exists(PATH) == true:
		if not file.eof_reached():
			var current_line = JSON.parse_string(file.get_line())
			var keys = current_line.keys()
			if current_line:
				if keys.has("Audio Settings"):
					audioSettings = current_line["Audio Settings"]
				if keys.has("Character Interactions"):
					characterInteractions = current_line["Character Interactions"]
				if keys.has("Items"):
					items = current_line["Items"]
				if keys.has("Unlocks"):
					unlocks = current_line["Unlocks"]
				if keys.has("Minigames"):
					minigames = current_line["Minigames"]
	
	if type == SaveTypes.SETTINGS:
		for key in audioSettings.keys():
			var bus = AudioServer.get_bus_index(key)
			AudioServer.set_bus_volume_db(bus, linear_to_db(audioSettings[key]))
			print(audioSettings)
