extends ItemBase

func _ready():
	parent.max_bullet_timer = 3
	parent.bullet_scene = load("res://minigames/karl_pilkington/assets/karl/bullets/stick/stick.tscn")
