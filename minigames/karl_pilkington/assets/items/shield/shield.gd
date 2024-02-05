extends ItemBase

var shield = load("res://minigames/karl_pilkington/assets/items/shield/picture.tscn")
func _ready():
	var shieldInstance = shield.instantiate()
	parent.call_deferred("add_child", shieldInstance)
	shieldInstance.pilkington = parent

