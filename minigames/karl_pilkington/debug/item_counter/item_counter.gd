extends Control

var items:int = 3

@onready var parent = global.sceneManager.get_node("Pilkington")

const item_dropdown = preload("res://minigames/karl_pilkington/debug/item_dropdown/item_dropdown.tscn")

func _ready():
	items = parent.custom_items
	change_items(0)

func change_items(amount:int = 0):
	items += amount
	items = clampi(items, 1, 5)
	print(items)
	
	$Text.text = "[center]" + str(items)
	
	parent.custom_items = items
	for i in range($ItemDropdowns.get_children().size()):
		if i > items - 1:
			$ItemDropdowns.get_children()[i].hide()
		else:
			$ItemDropdowns.get_children()[i].show()
	
	parent.check_debug()


func _on_minus_button_pressed():
	change_items(-1)
func _on_plus_button_pressed():
	change_items(1)
