extends Node2D

@onready var parent  = global.sceneManager.get_node("Pilkington")

var curSelected:int = 0

@onready var optionArray = [$Retry, $Menu]

func _ready():
	changeSelection(0)
	$ColorRect.visible = true

func _process(delta):
	$ColorRect.modulate.a -= delta
	if Input.is_action_just_pressed("left"):
		changeSelection(-1)
	if Input.is_action_just_pressed("right"):
		changeSelection(1)
	
	if Input.is_action_just_pressed("ui_accept"):
		match curSelected:
			0:
				parent.changeScene("res://minigames/karl_pilkington/select menu/upgrade_menu.tscn")
			1:
				if global.enteredMiniGameFromMenu:
					Transition.change_scene_to_preset("Main Menu")
				else:
					parent.changeScene("res://minigames/karl_pilkington/menu/pilkington menu.tscn")

func changeSelection(amount):
	curSelected += amount
	if curSelected > optionArray.size() - 1:
		curSelected = 0
	if curSelected < 0:
		curSelected = optionArray.size() - 1
	for i in optionArray.size():
		if i != curSelected:
			optionArray[i].modulate.a = 0.2
			#optionArray[i].scale = Vector2(0.85, 0.85)
		else:
			optionArray[i].modulate.a = 1
			#optionArray[i].scale = Vector2(1, 1)
