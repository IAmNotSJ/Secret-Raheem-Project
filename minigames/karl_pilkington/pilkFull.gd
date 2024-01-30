extends Node2D

var pilkPath:String

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
