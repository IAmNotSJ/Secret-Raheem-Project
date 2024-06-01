extends OptionButton

@onready var parent = global.sceneManager.get_node("Pilkington")

@export var index = 0

func _ready():
	for i in range(parent.customItemList.size()):
		add_item(parent.customItemList[i])
	if parent.custom_item_array[index] == "Random":
		selected = 100
	else:
		selected = parent.customItemList.find(parent.custom_item_array[index]) + 1


func _on_item_selected(daIndex):
	parent.custom_item_array[index] = get_item_text(daIndex)
	print(parent.custom_item_array)
	
	parent.check_debug()
