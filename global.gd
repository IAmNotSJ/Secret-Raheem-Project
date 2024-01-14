extends Node

const SAVE_PATH = "user://overworld.save"
@onready var music = $Music

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
}

func _ready():
	load_save()

func add_interaction(character:String):
	if character == null:
		print("Invalid Character")
	elif characterInteractions.get(character) == null:
		print("Character Does Not Exist!")
	else:
		characterInteractions[character] += 1
		save()

func save():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	var data:Dictionary = {
		"Character Interactions": characterInteractions
	}
	var jstr = JSON.stringify(data)
	
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
