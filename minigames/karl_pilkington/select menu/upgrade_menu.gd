extends Node2D

const upgradeScene = preload("res://minigames/karl_pilkington/select menu/upgrade.tscn")

var upgradeCount = 3
var upgrades = [
	["Blocky Chair", "So Slush!", "res://minigames/karl_pilkington/assets/karl/pilkingtons/chair/pilkington.tscn", preload("res://minigames/karl_pilkington/select menu/upgrade icons/chair.png")],
	["Clickbait", "Anything for views", "res://minigames/karl_pilkington/assets/karl/pilkingtons/awful/pilkington.tscn", preload("res://minigames/karl_pilkington/select menu/upgrade icons/clickbait.png")],
	["The Cookie", "HAHAHAHAHHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHA", "res://minigames/karl_pilkington/assets/karl/pilkingtons/weed/pilkington.tscn", preload("res://minigames/karl_pilkington/select menu/upgrade icons/cookie.png")],
	["Guardian Angel", "Always has your back", "res://minigames/karl_pilkington/assets/karl/pilkingtons/shield/pilkington.tscn", preload("res://minigames/karl_pilkington/select menu/upgrade icons/guardian.png")],
	["Mini Mushroom", "You're tiny!", "res://minigames/karl_pilkington/assets/karl/pilkingtons/mini/pilkington.tscn", preload("res://minigames/karl_pilkington/select menu/upgrade icons/mini.png")],
	["Garlic", "Really?\n(Space for Special)", "res://minigames/karl_pilkington/assets/karl/pilkingtons/garlic/pilkington.tscn", preload("res://minigames/karl_pilkington/select menu/upgrade icons/garlic.png")]
	]

func _ready():
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_VISIBLE)
	
	upgrades.shuffle()
	for i in range(upgradeCount):
		var upgrade = upgradeScene.instantiate()
		upgrade.createUpgrade(upgrades[i][0],upgrades[i][1],upgrades[i][2],upgrades[i][3])
		$CenterContainer/HBoxContainer.add_child(upgrade)
		#upgrade.position = Vector2(upgradeSeperation + upgradeSeperation*i, 720/2 - upgrade.get_node("CenterContainer").size.y)
