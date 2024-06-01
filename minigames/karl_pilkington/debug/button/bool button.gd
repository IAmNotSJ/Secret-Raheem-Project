extends Label

@onready var parent = global.sceneManager.get_node("Pilkington")

@export var displayOption:String
@export var debugOption:String

func _ready():
	text = displayOption
	if parent.debugOptions.keys().has(debugOption):
		%OptionButton.button_pressed = parent.debugOptions[debugOption]

func _on_option_button_toggled(toggled_on):
	if parent.debugOptions.keys().has(debugOption):
		parent.debugOptions[debugOption] = toggled_on
		parent.check_debug()
