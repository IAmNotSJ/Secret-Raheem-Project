extends Node

const SAVE_PATH = "user://overworld.save"
@onready var music = $Music

var rng = RandomNumberGenerator.new()

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
	pass

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
