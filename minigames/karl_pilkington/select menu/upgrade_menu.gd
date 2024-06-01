extends Node2D

@onready var parent = global.sceneManager.get_node("Pilkington")

const upgradeScene = preload("res://minigames/karl_pilkington/select menu/upgrade.tscn")

var upgrades = [
	["Blocky Chair", "So Slush!", "res://minigames/karl_pilkington/assets/items/chair/chair.tscn", preload("res://minigames/karl_pilkington/select menu/upgrade icons/chair.png")],
	["Clickbait", "Anything for views", "res://minigames/karl_pilkington/assets/items/awful/awful.tscn", preload("res://minigames/karl_pilkington/select menu/upgrade icons/clickbait.png")],
	["The Cookie", "HAHAHAHAHHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHA", "res://minigames/karl_pilkington/assets/items/weed/weed.tscn", preload("res://minigames/karl_pilkington/select menu/upgrade icons/cookie.png")],
	["Guardian Angel", "Always has your back", "res://minigames/karl_pilkington/assets/items/shield/shield.tscn", preload("res://minigames/karl_pilkington/select menu/upgrade icons/guardian.png")],
	["Mini Mushroom", "You're tiny!", "res://minigames/karl_pilkington/assets/items/mini/mini.tscn", preload("res://minigames/karl_pilkington/select menu/upgrade icons/mini.png")],
	["Garlic", "Really?\n(Space for Special)", "res://minigames/karl_pilkington/assets/items/garlic/garlic.tscn", preload("res://minigames/karl_pilkington/select menu/upgrade icons/garlic.png")],
	["The Stick", "It's in self defense", "res://minigames/karl_pilkington/assets/items/stick/stick.tscn", preload("res://minigames/karl_pilkington/select menu/upgrade icons/garlic.png")]
	]

func _ready():
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_VISIBLE)
	upgrades.shuffle()
	
	var custom_items = parent.custom_item_array
	
	var upgradeCount = parent.custom_items
	for i in range(upgradeCount):
		if custom_items[i] == "Random":
			var upgrade = upgradeScene.instantiate()
			upgrade.createUpgrade(upgrades[i][0],upgrades[i][1],upgrades[i][2],upgrades[i][3])
			%HBoxContainer.add_child(upgrade)
			#upgrade.position = Vector2(upgradeSeperation + upgradeSeperation*i, 720/2 - upgrade.get_node("CenterContainer").size.y)
			match upgradeCount:
				1:
					upgrade.change_scale(1.2)
				2:
					upgrade.change_scale(1.1)
				4:
					upgrade.change_scale(0.9)
					%HBoxContainer.add_theme_constant_override("separation", 300)
				5:
					upgrade.change_scale(0.8)
					%HBoxContainer.add_theme_constant_override("separation", 250)
		else:
			var intended_upgrade = custom_items[i]
			for j in range(upgrades.size()):
				if upgrades[j][0] == intended_upgrade:
					var upgrade = upgradeScene.instantiate()
					upgrade.createUpgrade(upgrades[j][0],upgrades[j][1],upgrades[j][2],upgrades[j][3])
					%HBoxContainer.add_child(upgrade)
					#upgrade.position = Vector2(upgradeSeperation + upgradeSeperation*i, 720/2 - upgrade.get_node("CenterContainer").size.y)
					match upgradeCount:
						1:
							upgrade.change_scale(1.2)
						2:
							upgrade.change_scale(1.1)
						4:
							upgrade.change_scale(0.9)
							%HBoxContainer.add_theme_constant_override("separation", 300)
						5:
							upgrade.change_scale(0.8)
							%HBoxContainer.add_theme_constant_override("separation", 250)
