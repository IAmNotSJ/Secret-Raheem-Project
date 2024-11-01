extends Node2D

@onready var sceneManager = get_tree().root.get_node("SceneManager")
@onready var mouse = $Mouse.get_node("Mouse")

const WEBHOOK_URL = "https://discord.com/api/webhooks/1279278515933679666/pL2CsmnHFZVozp1fkwophAjb4KDc5fxG9mIqIoqO5YhE9yGzERu7rYtsC_sDKaCULbe5"

var isWindowFocused:bool = true
var isMouseInside:bool = true

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
	
	var webhook := DiscordWebHook.new(WEBHOOK_URL)
	var embed = webhook.add_embed()
	embed.set_title("MATCH SET") 
	embed.set_description("This is my embeds description")
	embed.set_color(Color8(66, 236, 255))
	embed.image("https://media.discordapp.net/attachments/1119033198551236783/1297062342948950026/image.jpg?ex=67148ef0&is=67133d70&hm=18aef4348cc63238c90d64ac185e2c9062e0702249667ee168b1ae49451719c7&=&format=webp&width=889&height=889")
	
	embed.add_field("Host", "Yo Mama")
	embed.add_field("Client", "Your Mom")
	embed.add_field("\u200B", "\u200B")
	embed.add_field("Messages Sent", "10000", true)
	embed.add_field("Turns", "0", true)
	
	
	#webhook.post()

func _input(_event: InputEvent) -> void:
	if get_viewport().get_camera_2d() != null:
		$mouse_area.global_position = get_global_mouse_position()
	else:
		$mouse_area.global_position = get_global_mouse_position()

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

func can_remove_coins(amount:int):
	if Saves.playerInfo["Copper Coins"] >= amount:
		return true
	else:
		return false
	

#Returns the amount of coins left after the transaction
func remove_coins(amount:int):
	if Saves.playerInfo["Copper Coins"] >= amount:
		Saves.playerInfo["Copper Coins"] -= amount
		Saves.save(Saves.SaveTypes.SETTINGS)
		print("Remaining Copper Coins: " + str(Saves.playerInfo["Copper Coins"]))
		return Saves.playerInfo["Copper Coins"]
	else:
		return -1

#Returns the amount of coins left after the addition
func add_coins(amount:int):
	Saves.playerInfo["Copper Coins"] += amount
	Saves.save(Saves.SaveTypes.SETTINGS)
	return Saves.playerInfo["Copper Coins"]

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
	var daMouse = $Mouse.get_node("Mouse")
	if daMouse.mouse_mode == daMouse.MouseMode.VISIBLE:
		daMouse.mouse_mode = daMouse.MouseMode.HIDDEN
	if daMouse.mouse_mode == daMouse.MouseMode.HIDDEN:
		daMouse.mouse_mode = daMouse.MouseMode.VISIBLE
