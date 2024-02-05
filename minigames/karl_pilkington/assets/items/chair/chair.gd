extends ItemBase

func _ready():
	parent.tears_per_shot = 4
	parent.walk_anim = false
	parent.bullet_scene = load("res://minigames/karl_pilkington/assets/karl/bullets/swirve/swirve_bullet.tscn")
