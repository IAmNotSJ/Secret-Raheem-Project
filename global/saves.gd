extends Node

enum SaveTypes {
	SETTINGS,
	OVERWORLD,
	HYENA,
	PILKINGTON,
	PAINT,
	BATTLE
}
const PATH_OVERWORLD:String = "user://overworld.save"
const PATH_SETTINGS:String = "user://settings.hellopersonlookingatthefiles"
const PATH_HYENA:String = "user://hyena.save"
const PATH_BATTLE:String = "user://raheem_battle.save"

# SETTINGS
var audioSettings:Dictionary = {
	"Master":1.0, 
	"Music": 1.0, 
	"SFX": 1.0}
# Time is the seconds in the save file
var playerInfo = {
	"Time" : 0,
	"Login Streak" : 0,
	"Copper Coins" : 0}

# OVERWORLD
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
	"Nova": 0}
var items:Dictionary = {
	"Key": false,
	"Pizza": false,
	"Composty Tokens" : 0}
var unlocks:Dictionary = {
	"Cleft": false,
	"Gate": false}
var minigames:Dictionary = {
	"Karl Pilkington" : false,
	"Hyena Clicker" : false}

# HYENA CLICKER
var hyena_stats = {
	"First Time" : true,
	"Hyenas" : "0",
	"Total Hyenas" : "0",
	"CurIdle" : 1,
	"CurClick" : 1,
	"Click Upgrades" : {},
	"Idle Upgrades" : {},
	"Clicks" : 0,
	"Highest CPS" : float(0)
}


# RAHEEM BATTLE
var battle_quiz = {
	"Server Member" : "Other",
	"Age" : 18,
	"Projects" : false,
	"Employment" : false,
	"Furry" : false,
	"Twitch" : false,
	"Math" : 0,
	"Autistic" : false,
	"Favorite Member" : "None",
	"Youtubers" : "Pewdiepie",
	"Lucky Number" : 0,
	"College Years" : 1,
	"Subscribers" : 0,
	"Speedrun" : false}
var battle_stats = {
	"Games Played" : 0,
	"Wins" : 0,
	"Losses" : 0,
	"Hyena Upgrades" : 0}

# KARL PILKINGTON


func _ready():
	load_save(SaveTypes.OVERWORLD)
	load_save(SaveTypes.SETTINGS)
	load_save(SaveTypes.HYENA)
	load_save(SaveTypes.BATTLE)

func save(type:SaveTypes):
	var PATH:String = ""
	match type:
		SaveTypes.OVERWORLD:
			PATH = PATH_OVERWORLD
		SaveTypes.SETTINGS:
			PATH = PATH_SETTINGS
		SaveTypes.HYENA:
			PATH = PATH_HYENA
		SaveTypes.BATTLE:
			PATH = PATH_BATTLE
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
				"Player Info" : playerInfo,
				"Audio Settings" : audioSettings
			}
		SaveTypes.HYENA:
			data = {
				"Hyena Stats" : hyena_stats,
			}
		SaveTypes.BATTLE:
			data = {
				"Battle Quiz" : battle_quiz,
				"Battle Stats" : battle_stats
			}
	var jstr = JSON.stringify(data)
	#print('saved!')
	
	file.store_line(jstr)

func load_save(type:SaveTypes):
	var PATH:String = ""
	match type:
		SaveTypes.OVERWORLD:
			PATH = PATH_OVERWORLD
		SaveTypes.SETTINGS:
			PATH = PATH_SETTINGS
		SaveTypes.HYENA:
			PATH = PATH_HYENA
		SaveTypes.BATTLE:
			PATH = PATH_BATTLE
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
				if keys.has("Player Info"):
					playerInfo = current_line["Player Info"]
				if keys.has("Character Interactions"):
					characterInteractions = current_line["Character Interactions"]
				if keys.has("Items"):
					load_specific_setting(items, current_line, "Items")
				if keys.has("Unlocks"):
					load_specific_setting(unlocks, current_line, "Unlocks")
				if keys.has("Minigames"):
					load_specific_setting(minigames, current_line, "Minigames")
				if keys.has("Battle Quiz"):
					load_specific_setting(battle_quiz, current_line, "Battle Quiz")
				if keys.has("Battle Stats"):
					load_specific_setting(battle_stats, current_line, "Battle Stats")
				if keys.has("Hyena Stats"):
					load_specific_setting(hyena_stats, current_line, "Hyena Stats")
	
	if type == SaveTypes.SETTINGS:
		for key in audioSettings.keys():
			var bus = AudioServer.get_bus_index(key)
			AudioServer.set_bus_volume_db(bus, linear_to_db(audioSettings[key]))
		print(audioSettings)

func load_specific_setting(setting_dict:Dictionary, current_line:Dictionary, daKey:String):
	for key in current_line[daKey].keys():
		if setting_dict.has(key):
			setting_dict[key] = current_line[daKey][key]
