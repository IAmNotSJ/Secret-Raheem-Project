extends ItemBase

func _ready():
	parent.max_bullet_timer = 0.1
	parent.bullet_scene = load("res://minigames/karl_pilkington/assets/karl/bullets/awful/awful_bullet.tscn")
	parent.include_bar = false
