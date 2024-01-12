@tool
class_name ParallaxTile extends TextureRect

@export var active:bool = false
@export var speed:float = 50

func _ready():
	active = true
func _process(delta):
	if active:
		position.x += speed * delta
		position.y += speed * delta
		if position.x >= -texture.get_width():
			position.x = -texture.get_width() * 2
			position.y = -texture.get_height() * 2
