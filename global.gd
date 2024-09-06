extends Node

@onready var sceneManager = get_tree().root.get_node("SceneManager")

const WEBHOOK_URL = "https://discord.com/api/webhooks/1279278515933679666/pL2CsmnHFZVozp1fkwophAjb4KDc5fxG9mIqIoqO5YhE9yGzERu7rYtsC_sDKaCULbe5"

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

var time_start = 0
var time_end = 0

func _ready():
	time_start = Time.get_unix_time_from_system()
	
	#var webhook := DiscordWebHook.new(WEBHOOK_URL)

	# Create the embed object and set some properties
	#var embed = webhook.add_embed()
	#embed.set_title("An awesome title") 
	#embed.set_description("This is my embeds description")
	#embed.set_color(Color.RED)
	
	#webhook.post()

func add_interaction(character:String):
	if character == null:
		print("Invalid Character")
	elif characterInteractions.get(character) == null:
		print("Character Does Not Exist!")
	else:
		characterInteractions[character] += 1
		#save()

func add_value(daSet, value:String):
	if value == null:
		print("Invalid Character")
	elif daSet.get(value) == null:
		print("Value Does Not Exist!")
	else:
		daSet[value] = true

func update_save_file_time():
	time_end = Time.get_unix_time_from_system()
	var time_elapsed = time_end - time_start
	time_start = Time.get_unix_time_from_system()
	Saves.playerInfo["Time"] += time_elapsed
	Saves.save(Saves.SaveTypes.SETTINGS)

func _notification(what):
	match what:
		NOTIFICATION_WM_WINDOW_FOCUS_OUT:
			#print('window unfocused!')
			isWindowFocused = false
		NOTIFICATION_WM_WINDOW_FOCUS_IN:
			#print('window focused!')
			isWindowFocused = true
		NOTIFICATION_WM_CLOSE_REQUEST:
			update_save_file_time()

func toggle_mouse_visibility():
	if $Mouse.mouse_mode == $Mouse.MouseMode.VISIBLE:
		$Mouse.mouse_mode = $Mouse.MouseMode.HIDDEN
	if $Mouse.mouse_mode == $Mouse.MouseMode.HIDDEN:
		$Mouse.mouse_mode = $Mouse.MouseMode.VISIBLE
