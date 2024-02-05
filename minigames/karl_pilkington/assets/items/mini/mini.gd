extends ItemBase

func _ready():
	parent.scale = Vector2(0.5, 0.5)
	parent.bullet_scene = load("res://minigames/karl_pilkington/assets/karl/bullets/mini/mini_bullet.tscn")
