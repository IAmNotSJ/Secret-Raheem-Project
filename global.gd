extends Node2D

@onready var sceneManager = get_tree().root.get_node("SceneManager")
@onready var mouse = $Mouse.get_node("Mouse")

const WEBHOOK_URL = "https://discord.com/api/webhooks/1304960804872912956/fSt4u2c4jrZwVNvWUyl1g4jWulhBEM8YNR8vW2-LSzVgAlN1WMoUE-UEH30sp8giE8ki"

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
	"Dapper": 0,
	"Composty": 0,
	"Dile": 0,
	"Atlas": 0,
	"Slime": 0,
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

func show_mouse():
	var daMouse = $Mouse.get_node("Mouse")
	
	daMouse.mouse_mode = daMouse.MouseMode.VISIBLE
