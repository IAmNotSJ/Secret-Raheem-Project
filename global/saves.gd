extends Node

enum SaveTypes {
	SETTINGS,
	OVERWORLD,
	HYENA,
	PILKINGTON,
	PAINT,
	BATTLE,
	SHOP
}
const PATH_OVERWORLD:String = "user://overworld.save"
const PATH_SETTINGS:String = "user://settings.hellopersonlookingatthefiles"
const PATH_HYENA:String = "user://hyena.save"
const PATH_BATTLE:String = "user://raheem_battle_demo.save"

# SETTINGS
var audioSettings:Dictionary = {
	"Master":1.0, 
	"Music": 1.0, 
	"SFX": 1.0}
var videoSettings:Dictionary = {
	"VSync" : false}
# Time is the seconds in the save file
var playerInfo = {
	"Time" : 0,
	"Last Login" : Time.get_unix_time_from_system(),
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
	"Object Show" : false,
	"Favorite Member" : "None",
	"Youtubers" : "Pewdiepie",
	"Lucky Number" : 0,
	"College Years" : 0,
	"Subscribers" : 0,
	"Most Views" : 0,
	"Speedrun" : false,
	"Country" : "United States"}
var battle_info = {
	"Name" : "",
	"Character" : "wibr",
	"Color" : [1, 1, 1]
}
var battle_stats = {
	"Games Played" : 0,
	"Wins" : 0,
	"Losses" : 0,
	"Hyena Upgrades" : 0}
var battle_deck = {
	"8 Cards" : ["-1", "-1", "-1", "-1", "-1", "-1", "-1", "-1"],
	"9 Cards" : ["-1", "-1", "-1", "-1", "-1", "-1", "-1", "-1", "-1"],
	"10 Cards" : ["-1", "-1", "-1", "-1", "-1", "-1", "-1", "-1", "-1", "-1"],
	"11 Cards" : ["-1", "-1", "-1", "-1", "-1", "-1", "-1", "-1", "-1", "-1", "-1"],
	"12 Cards" : ["-1", "-1", "-1", "-1", "-1", "-1", "-1", "-1", "-1", "-1", "-1", "-1"],
}
var battle_unlocks = {
	"000" : 1,
	"001" : 1,
	"002" : 1,
	"003" : 1,
	"004" : 1,
	"005" : 1,
	"006" : 1,
	"007" : 1,
	"008" : 1,
	"009" : 1,
	"010" : 1,
	"011" : 1,
	"012" : 1,
	"013" : 1,
	"014" : 1,
	"015" : 1,
	"016" : 1,
	"017" : 1,
	"018" : 1,
	"019" : 1,
	"020" : 1,
	"021" : 1,
	"022" : 1,
	"023" : 1,
	"024" : 1,
	"025" : 1,
	"026" : 1,
	"027" : 1,
	"028" : 1,
	"029" : 1,
	"030" : 1,
	"031" : 1,
	"032" : 1,
	"033" : 1,
	"034" : 1,
	"035" : 1,
	"036" : 1,
	"037" : 1,
	"038" : 1,
	"039" : 1,
	"040" : 1,
	"041" : 1,
	"042" : 1,
	"043" : 1,
	"044" : 1,
	"045" : 1,
	"046" : 1,
	"047" : 1,
	"048" : 1,
	"049" : 1,
	"050" : 1,
	"051" : 1,
	"052" : 1,
	"053" : 1,
	"054" : 1,
	"055" : 1,
	"056" : 1,
	"057" : 1,
	"058" : 1,
	"059" : 1,
	"060" : 1,
	"061" : 1,
	"062" : 1,
	"063" : 1,
	"064" : 1,
	"065" : 1,
	"066" : 1,
	"067" : 1,
	"068" : 1,
	"069" : 1,
	"070" : 1,
	"071" : 1,
	"072" : 1,
	"073" : 1,
	"074" : 1,
	"075" : 1,
	"076" : 1,
	"077" : 1,
	"078" : 1,
	"079" : 1,
	"080" : 1,
	"081" : 1,
	"082" : 1,
	"083" : 1,
	"084" : 1,
	"085" : 1,
	"086" : 1,
	"087" : 1,
	"088" : 1,
	"089" : 1,
	"090" : 1,
	"091" : 1,
	"092" : 1,
	"093" : 1,
	"094" : 1,
	"095" : 1,
	"096" : 1,
	"097" : 1,
	"098" : 1,
	"099" : 1,
	"100" : 1,
	"101" : 1,
	"102" : 1,
	"103" : 1,
	"104" : 1,
	"105" : 1,
	"106" : 1,
	"107" : 1,
	"108" : 1,
	"109" : 1,
	"110" : 1,
	"111" : 1,
	"112" : 1,
	"113" : 1,
	"114" : 1,
	"115" : 1,
	"116" : 1,
	"117" : 1,
	"118" : 1,
	"119" : 1,
	"120" : 1,
	"121" : 1,
	"122" : 1,
	"123" : 1,
	"124" : 1,
	"125" : 1,
	"126" : 1,
	"127" : 1,
	"128" : 1,
	"129" : 1,
	"130" : 1,
	"131" : 1,
	"132" : 1,
	"133" : 1,
	"134" : 1,
	"135" : 1,
	"136" : 1,
	"137" : 1,
	"138" : 1,
	"139" : 1,
	"140" : 1,
	"141" : 1,
	"142" : 1,
	"143" : 1,
	"144" : 1,
	"145" : 1,
	"146" : 1,
	"147" : 1,
	"148" : 1,
	"149" : 1,
	"150" : 1,
	"151" : 1,
	"152" : 1,
	"153" : 1,
	"154" : 1,
	"155" : 1,
	"156" : 1
}
var battle_settings = {
	"UPNP" : true,
	"DayNight" : true,
	"Censor Food" : false,
}
var battle_rules = {
	"Deck Size" : "8 Cards",
	"Cards To Win" : 2
}
var battle_diary = {}
# KARL PILKINGTON

# MONIKA SHOP
var cursors = {
	"Default" : true,
	"Raheem" : false,
	"Wibr" : false,
	"Monika" : false
}

func _ready():
	load_save(SaveTypes.OVERWORLD)
	load_save(SaveTypes.SETTINGS)
	load_save(SaveTypes.HYENA)
	load_save(SaveTypes.BATTLE)
	
	var difference:float = float(playerInfo["Last Login"] - Time.get_unix_time_from_system()) / float(24 * 60 * 60)
	if difference > 1 and difference < 2:
		playerInfo["Login Streak"] += 1
	elif difference > 2:
		playerInfo["Login Streak"] = 0
	
	print(playerInfo["Login Streak"])
	
	playerInfo["Last Login"] = Time.get_unix_time_from_system()
	
	save(SaveTypes.SETTINGS)
	
	# APPLY SETTIGNS!
	if videoSettings["VSync"]:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	
	print(battle_info["Color"])

# Copper Coin Jazz #

func can_remove_coins(amount:int):
	if playerInfo["Copper Coins"] >= amount:
		return true
	else:
		return false

#Returns the amount of coins left after the transaction
func remove_coins(amount:int):
	if playerInfo["Copper Coins"] >= amount:
		playerInfo["Copper Coins"] -= amount
		save(Saves.SaveTypes.SETTINGS)
		print("Remaining Copper Coins: " + str(playerInfo["Copper Coins"]))
		return playerInfo["Copper Coins"]
	else:
		return -1

#Returns the amount of coins left after the addition
func add_coins(amount:int):
	playerInfo["Copper Coins"] += amount
	save(SaveTypes.SETTINGS)
	return playerInfo["Copper Coins"]

func get_coins():
	return playerInfo["Copper Coins"]

# Saving / Loading #

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
				"Audio Settings" : audioSettings,
				"Video Settings" : videoSettings
			}
		SaveTypes.HYENA:
			data = {
				"Hyena Stats" : hyena_stats,
			}
		SaveTypes.BATTLE:
			data = {
				"Battle Quiz" : battle_quiz,
				"Battle Stats" : battle_stats,
				"Battle Deck" : battle_deck,
				"Battle Info" : battle_info,
				"Battle Settings" : battle_settings,
				"Battle Rules" : battle_rules
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
					load_specific_setting(audioSettings, current_line, "Audio Settings")
				if keys.has("Video Settings"):
					load_specific_setting(videoSettings, current_line, "Video Settings")
				if keys.has("Player Info"):
					load_specific_setting(playerInfo, current_line, "Player Info")
				if keys.has("Character Interactions"):
					load_specific_setting(characterInteractions, current_line, "Character Interactions")
				if keys.has("Items"):
					load_specific_setting(items, current_line, "Items")
				if keys.has("Unlocks"):
					load_specific_setting(unlocks, current_line, "Unlocks")
				if keys.has("Minigames"):
					load_specific_setting(minigames, current_line, "Minigames")
				if keys.has("Battle Quiz"):
					load_specific_setting(battle_quiz, current_line, "Battle Quiz")
				if keys.has("Battle Rules"):
					load_specific_setting(battle_rules, current_line, "Battle Rules")
				if keys.has("Battle Stats"):
					load_specific_setting(battle_stats, current_line, "Battle Stats")
				if keys.has("Battle Deck"):
					load_specific_setting(battle_deck, current_line, "Battle Deck")
				if keys.has("Battle Info"):
					load_specific_setting(battle_info, current_line, "Battle Info")
				if keys.has("Battle Settings"):
					load_specific_setting(battle_settings, current_line, "Battle Settings")
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
