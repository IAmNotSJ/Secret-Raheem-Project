extends Node2D

var pilkPath:String

#Used as a reference for what is a "proper" value for a debug option
#If one is not right, enable the cheating variable
var debugOptionsStandard:Dictionary = {
	"Invincibility" : false,
	"Spawn Enemies" : true,
	"Spawn Dummy" : false
}
var debugOptions:Dictionary = {
	"Invincibility" : false,
	"Spawn Enemies" : true,
	"Spawn Dummy" : false
}

var customItemList:Array = [
	"Blocky Chair",
	"Clickbait", 
	"The Cookie",
	"Guardian Angel",
	"Mini Mushroom", 
	"Garlic",
	"The Stick"
]

# Checks to see if theres anything in here other than "Random" when calculating upgrades.
# If yes, add the upgrade to the designated index. 
var custom_item_array = ["Random", "Random", "Random", "Random", "Random"]

var custom_items:int = 3

var usesDebug:bool = false

const SAVE_PATH: String = "user://pilkington.save"

@onready var currentScene = $PilkingtonMenu

var hasWon:bool = false

func _ready():
	save()

func changeScene(target:String, transition:bool = true):
	var newScene = load(target).instantiate()
	
	if transition:
		Transition.animationPlayer.play('trans')
		await(Transition.animationPlayer.animation_finished)
	
	add_child(newScene)
	currentScene.queue_free()
	currentScene = newScene
	
	if transition:
		Transition.animationPlayer.play('trans_back')

func check_debug():
	print('checking!')
	var cheating = false
	for i in range(debugOptions.keys().size()):
		if debugOptions[debugOptions.keys()[i]] != debugOptionsStandard[debugOptions.keys()[i]]:
			cheating = true
	if custom_items != 3:
		cheating = true
	
	for i in range(custom_items):
		if custom_item_array[i] != "Random":
			print(custom_item_array[i])
			cheating = true
	
	usesDebug = cheating

func save():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	var data:Dictionary = {
		"Has Won": hasWon
	}
	var jstr = JSON.stringify(data)
	
	file.store_line(jstr)
func load_save():
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		print('poo no')
		return
	if file == null:
		print('poo null')
		return
	if FileAccess.file_exists(SAVE_PATH) == true:
		if not file.eof_reached():
			var current_line = JSON.parse_string(file.get_line())
			if current_line:
				
				hasWon = current_line["Has Won"]
